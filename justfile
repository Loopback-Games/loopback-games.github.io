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

# Check formatting without writing.
lint:
    npx --yes prettier@3 --check "*.html" "*.css" "*.md"

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
    npx --yes pa11y@9 --standard WCAG2AA "http://127.0.0.1:{{port}}/"
    npx --yes pa11y@9 --standard WCAG2AA "http://127.0.0.1:{{port}}/404.html"

# Remove local scratch output.
clean:
    rm -rf node_modules
