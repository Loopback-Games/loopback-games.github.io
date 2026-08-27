# Working in this repository

## The rule

**A workflow must never carry a command a developer cannot run locally.**

Every command lives in the `justfile`, and `.github/workflows/ci.yml` runs
`just ci` — one step, no inline shell. If CI needs to do something new, it gets
a recipe first.

CI carried five jobs and called the justfile from none of them. Three were
inline shell duplicating a recipe on this page; two existed nowhere a developer
could reach. Nothing pinned a tool, and every Node tool arrived through
`npx --yes <pkg>@<major>` at run time.

## Tools

Tool versions live in `mise.toml` and nowhere else — not in a workflow, not in
`package.json`, not in a README. CI installs that same file with
`jdx/mise-action`, so a version bump happens in one place. `package.json`'s
`engines` states the minimum and follows the pin; it does not compete with it.

`just setup` installs everything. The justfile puts `node_modules/.bin` and then
mise's shims on `PATH`, so recipes work whether or not your shell has activated
mise. Never reintroduce `npx --yes`: it fetches a tool that is not installed, at
run time, unpinned within the major, which is the failure this toolchain exists
to prevent.

The Python side goes through `uv`, which owns the environment; mise only pins
the interpreter it uses. Pillow is a declared dependency in `pyproject.toml`
now — it used to be an undeclared import in `tools/build-hd.py` that happened to
work on machines that already had it.

Dependabot has no mise ecosystem, so those pins are bumped by hand with
`mise upgrade`.

## The container

`.devcontainer/Containerfile` builds on Playwright's official image, so the
browser the accessibility suite drives comes with it. CI runs on a plain runner
and installs the browser instead — this repository's suite is two static pages
and axe, so the parity is not worth a second job.

`just markup` is the exception to the rule at the top: it runs the W3C validator
in a digest-pinned container, so it cannot run inside `just container` — you
cannot nest container engines. It is therefore outside `just ci` and inside
`just check`, and CI gives it its own job. It picks podman or docker, whichever
is present.

## Formatting

Prettier, pinned in `devDependencies` rather than fetched with `npx --yes`.
Two exclusions, both deliberate: `.github/`, because `yamllint --strict` wants
two spaces before an inline comment and prettier collapses them to one; and
`style.css`, because it carries a generated block between the `SPRITES:`
markers.

There is no TypeScript and no ESLint. The page ships no JavaScript at all —
`just no-js` fails the build if a `<script>` tag, a `javascript:` URL or an
inline handler appears, and the accessibility suite checks the same thing in the
browser.

## Actions

Pinned by commit SHA with the version in a trailing comment. Resolve a SHA with
`gh api repos/<owner>/<repo>/git/ref/tags/<tag>` — never copy one from memory.
`actionlint` and `zizmor` run in `just lint-config`.

## Before you push

`just check` — it is `ci` plus the markup validation, which is the combination
CI covers across its two jobs.

There is no `build` recipe and there should not be one. Pages serves `main`
directly: what is committed is what is served. `just sprites` and `just hd`
regenerate committed artefacts, and `just lint` fails if either is stale.
