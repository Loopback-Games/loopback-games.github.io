# loopback-games.github.io

The Loopback Games landing page. Three static files and a folder of assets,
served straight from `main` by GitHub Pages at
<https://loopback-games.github.io/>.

## Rules this repo keeps

- **No JavaScript.** Not a `<script>` tag, not an inline handler. CI fails the
  build if one appears.
- **No build step.** What is committed is what is served.
- **No external requests at runtime.** The font is self-hosted, the images are
  local. The page renders with the network cut after first load.

## Layout

```
index.html    the page
404.html      not-found page, same stylesheet
style.css     all of it
assets/       logo, favicons, social card, the pixel font and its licence
```

## Working on it locally

```sh
just serve     # http://127.0.0.1:8765
just check     # zero-JS guard, link check, accessibility audit
```

Without `just`, `python3 -m http.server 8765` does the same job.

## Adding a game

1. Copy one of the three `<li class="card">` blocks in `index.html`.
2. Change the accent class (`card--wages`, `card--pinball`, `card--looplings`)
   to a new one, and add a matching `--accent` rule in `style.css` next to the
   others.
3. Update the count in the `#titles` heading, which is written out in words.

The grid reflows on its own; no other change is needed.

## Credits

Press Start 2P by CodeMan38, used under the SIL Open Font License 1.1. The
licence travels with the font in `assets/press-start-2p-OFL.txt`.

Everything else is MIT licensed. See [LICENSE](LICENSE).
