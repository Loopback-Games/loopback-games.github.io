# Loopback Games landing page — task runner.
#
# This is the only interface, and the workflows run these same recipes rather
# than spelling them out again in YAML. CI used to carry five jobs, three of
# which duplicated a recipe on this page and two of which existed nowhere else.
#
# Tool versions come from mise.toml. `just setup` installs them.

set shell := ["bash", "-euo", "pipefail", "-c"]

# The project's own binaries first, then mise's shims. Every Node tool here used
# to arrive through `npx --yes <pkg>@<major>` at run time — unpinned within the
# major, no lockfile, and a network round trip on every lint.
export PATH := justfile_directory() / "node_modules/.bin" + ":" + (env("HOME") / ".local/share/mise/shims") + ":" + env("PATH")

# The digest-pinned W3C Nu Html Checker. A container rather than a mise pin
# because vnu is a Java program, and pulling a JRE in to validate two static
# files costs more than it saves.
validator := "ghcr.io/validator/validator@sha256:3f0f5a507c1b93960145f9ceb9df2981eb3e9b092444aae29cb941cfabf5e824"

# Port the static server and the accessibility suite share.
port := "8765"

# List the available recipes.
default:
    @just --list

# Everything a fresh clone needs before it can run anything else.
setup: install browsers

# Install the pinned toolchain, the Python environment and the npm tree.
install:
    mise trust --quiet
    mise install --yes
    uv sync
    npm ci

# The only recipe that is allowed to change package-lock.json.

# Re-resolve the dependency tree and write the lockfile.
update:
    npm install
    uv lock --upgrade

# The OS libraries have to come from somewhere, and `--with-deps` installs them
# through apt — so it works on the Ubuntu runner and in the devcontainer, and
# fails outright on a Fedora host. A no-op once the browser is on the machine.

# Fetch the browser the accessibility suite drives.
browsers:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -n "${PLAYWRIGHT_BROWSERS_PATH:-}" ]]; then
        echo "browsers already in the image at ${PLAYWRIGHT_BROWSERS_PATH}"
    elif command -v apt-get >/dev/null 2>&1; then
        playwright install --with-deps chromium
    else
        playwright install chromium
    fi

# Format the page. style.css is excluded: it carries a generated block.
fmt:
    prettier --write .

# Everything static, in one recipe: the zero-JS rule, the generated assets, the
# configuration and the formatting.

# Check everything that does not need a browser.
lint: no-js sprites-current hd-present lint-config
    prettier --check .

# No "not installed, skipping" guards. actionlint and zizmor come from
# mise.toml, so they are always present. This replaces the inline
# `python3 -c "import yaml, glob; ..."` parse check, which is why PyYAML is no
# longer an undeclared dependency: these two read the same files and do more.

# Workflows and the YAML around them.
lint-config:
    actionlint
    zizmor --min-severity low .github/workflows
    yamllint --strict .github .yamllint

# Fail if any JavaScript has crept into the page.
no-js:
    #!/usr/bin/env bash
    set -euo pipefail
    if grep -RniE '<script|javascript:|\son[a-z]+\s*=' -- *.html; then
        echo "JavaScript found. This site ships none." >&2
        exit 1
    fi
    echo "No JavaScript. Good."

# Expand tools/sprites/*.txt into the generated block in style.css.
sprites:
    python3 tools/build-sprites.py

# Fail if style.css no longer matches the sprite matrices.
sprites-current:
    python3 tools/build-sprites.py --check

# Through `uv run`, because this is the one thing here that needs Pillow. The
# --check path deliberately does not: it only looks for the output files, so CI
# never installs a Python package.

# Rebuild the upgraded sprites from the CC0 art in hd-src/.
hd:
    uv run python tools/build-hd.py

# Fail if the upgraded sprites are missing.
hd-present:
    python3 tools/build-hd.py --check

# WCAG 2 AA on both pages, through axe inside Playwright. This replaces pa11y,
# which drove a second headless browser through puppeteer and needed
# --no-sandbox to do it.

# Audit both pages for accessibility.
test *args: browsers
    playwright test {{ args }}

# Kept out of `ci` because it needs a container engine, and `just container`
# runs `just ci` inside a container — which cannot nest. The CI workflow gives
# it its own job so it still gates every push.

# Validate the markup with the W3C Nu Html Checker.
markup:
    #!/usr/bin/env bash
    set -euo pipefail
    # podman first, because that is what this project uses locally; the GitHub
    # runner has docker. Detected rather than configured, so `just markup` is
    # the same command in both places.
    engine="$(command -v podman || command -v docker)"
    # The ",z" is a shared SELinux relabel. Shared rather than private because
    # the devcontainer already mounts this tree, and a private label would take
    # it away from whatever else is holding it.
    "$engine" run --rm -v "$PWD:/src:ro,z" {{ validator }} \
        vnu --errors-only --skip-non-html /src/index.html /src/404.html

# There is no `build` recipe on purpose. Pages serves this repository's `main`
# directly: what is committed is what is served, and a `dist/` would contradict
# the rule the README states. `sprites` and `hd` regenerate committed artefacts,
# and `lint` fails if either is stale.

# Secrets in the history, and advisories against the dependencies.
security:
    gitleaks git . --no-banner --redact
    npm audit --audit-level=high

# Serve the site locally.
run:
    @echo "http://127.0.0.1:{{ port }}"
    python3 -m http.server {{ port }} --bind 127.0.0.1

# Everything CI runs in its main job, in the order it runs them.
ci: install lint security test

# The same gates plus the markup check, which needs a container engine the
# devcontainer does not have.

# Every gate, for a quick loop before pushing.
check: lint security test markup

# Run the full gate inside the devcontainer.
container:
    devcontainer up --docker-path podman --workspace-folder .
    devcontainer exec --docker-path podman --workspace-folder . just ci

# Remove local scratch output.
clean:
    rm -rf node_modules .venv test-results playwright-report tools/__pycache__
