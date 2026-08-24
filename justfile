# Loopback Games landing page

port := "8765"

# List the available recipes.
default:
    @just --list

# Serve the site locally.
serve:
    @echo "http://127.0.0.1:{{port}}"
    python3 -m http.server {{port}} --bind 127.0.0.1

# Format the HTML and CSS.
fmt:
    npx --yes prettier@3 --write "*.html" "*.css" "*.md"

# Expand tools/sprites/*.txt into the generated block in style.css.
sprites:
    python3 tools/build-sprites.py

# Check formatting without writing.
lint: workflows sprites-current hd-present
    npx --yes prettier@3 --check "*.html" "*.css" "*.md"

# Fail if style.css no longer matches the sprite matrices.
sprites-current:
    python3 tools/build-sprites.py --check

# Parse the workflow files. A stray colon in a step name breaks the run
# before any job starts, and GitHub reports that with no logs at all.
workflows:
    python3 -c "import yaml,glob,sys; [yaml.safe_load(open(f)) for f in glob.glob('.github/workflows/*.yml')]; print('workflows parse')"

# Fail if any JavaScript has crept into the page.
no-js:
    #!/usr/bin/env bash
    set -euo pipefail
    if grep -RniE '<script|javascript:|\son[a-z]+\s*=' -- *.html; then
        echo "JavaScript found. This site ships none." >&2
        exit 1
    fi
    echo "No JavaScript. Good."

# Run every check against a locally served copy.
check: no-js lint
    #!/usr/bin/env bash
    set -euo pipefail
    python3 -m http.server {{port}} --bind 127.0.0.1 >/dev/null 2>&1 &
    server=$!
    trap 'kill $server' EXIT
    sleep 1
    npx --yes pa11y@9 --config .pa11y.json "http://127.0.0.1:{{port}}/"
    npx --yes pa11y@9 --config .pa11y.json "http://127.0.0.1:{{port}}/404.html"

# Remove local scratch output.
clean:
    rm -rf node_modules

# Rebuild the upgraded sprites from the CC0 art in hd-src/.
hd:
    python3 tools/build-hd.py

# Fail if the upgraded sprites are missing.
hd-present:
    python3 tools/build-hd.py --check
