# Loopback Games landing page — design

Date: 2026-08-24

## Goal

A zero-JavaScript landing page for the Loopback Games catalogue, styled as 8/16-bit
pixel art, served from `https://loopback-games.github.io/` via GitHub Pages.

## Constraints

- **No JavaScript.** Not a single `<script>` tag, inline handler, or `javascript:` URL.
- **No build step.** GitHub Pages serves the repository root as-is.
- **No external network requests at runtime.** Fonts and images are self-hosted.
- Dark-only colour scheme, matching the games it links to.

## Catalogue

Derived from the public repositories under the `Loopback-Games` organisation.
`quarter-zip` was deleted from the organisation during design and is excluded.

| Repo        | Title            | Live URL                                    |
| ----------- | ---------------- | ------------------------------------------- |
| `larry`     | Lost Wages       | https://loopback-games.github.io/larry/     |
| `pinball`   | Loopback Pinball | https://loopback-games.github.io/pinball/   |
| `looplings` | Looplings        | https://loopback-games.github.io/looplings/ |

## Structure

Flat repository root, served directly:

```
index.html          the page
404.html            same shell, not-found copy
style.css           all styling
assets/
  logo.png          shield mark, from loopback_games.png
  og.jpg            social card, from loopback_games_full.jpeg
  favicon.png       derived from the shield mark
  press-start-2p.woff2
```

## Visual design

- **Type.** Press Start 2P (SIL OFL 1.1) self-hosted as `woff2` for the wordmark,
  headings and card titles. System monospace stack for body copy, because Press
  Start 2P is unreadable past a short phrase.
- **Palette.** Taken from the logo: near-black ground `#0b0b12`, cyan `#4ee6d8`,
  violet `#8b6cf0`, magenta `#ff5cf4`. One accent hue per game card.
- **Pixel idiom.** Hard-edged borders, no border-radius, no blur, offset block
  shadows instead of soft drop shadows, `image-rendering: pixelated` on raster art.
- **Motion.** Respects `prefers-reduced-motion`. All interaction states are CSS-only.

## Sections

1. Logo lockup and wordmark.
2. Game grid — CSS grid, `repeat(auto-fit, minmax(...))`, one column on phones.
   Each card: pixel title, one-line hook, short description, `PLAY` link to the
   live game, source link to the repository.
3. Footer — organisation link, MIT licence, copyright.

A "How these are made" section describing the AI-agent-built, no-asset-files
angle was built and then cut at review: the page is a catalogue, and the
studio's method is not what a visitor arrives for.

## Deployment

GitHub Pages, source `main` branch, `/` root. No Actions deploy workflow required.

## Verification

Before push: local HTTP server, Playwright screenshots at 390px and 1440px
viewports, `pa11y` accessibility audit, and a grep asserting zero `<script>` tags.

After push: poll the live origin for HTTP 200, assert the stylesheet, font and
images resolve, re-screenshot the live page, and confirm all three game links
still return 200 from production.
