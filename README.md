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

## The crew

Eight small characters live on the page and interfere with it. There is no
script and no sequence of scenes: each one runs on its own clock, between five
and fourteen seconds, so what you catch them doing depends on when you look.

They work on the real page, not on a picture of it:

| Who                    | What they get up to                                        |
| ---------------------- | ---------------------------------------------------------- |
| A ball on the wordmark | Bounces along the letters, which flinch on each landing    |
| A runner in the hero   | Crosses it, somersaults over the status line, belly-flops  |
| A thief in the heading | Drags the word "playable" out of the sentence and drops it |
| A mugger in Lost Wages | Wrenches the `Play` button out of the card and hurls it    |
| A rider on Pinball     | Uses the card's right frame as a banister                  |
| A ball at Looplings    | Rolls the length of the card and shoulders it out of true  |
| Two on the footer rule | Kick each other off it, take turns losing                  |

Each character is anchored **inside** the element it torments — the thief is a
child of the `<span>` around the word, the mugger sits in the button row — so
wherever the layout puts that element, its resident goes too. Contact is exact
at every width without one hard-coded coordinate.

Three properties the page has to keep, and the tests that hold it to them:

- **Nothing is clickable that should not be.** The crew is `pointer-events:
none` and `aria-hidden`. The `Play` elements were already decorative spans —
  the whole card is the link — so throwing one breaks no control.
- **Nothing moves the layout.** Every antic is `translate`, `rotate` or
  `scale`, none of which reflow anything. The card's shove uses `rotate` alone
  so it never fights the hover `translate`.
- **Nothing scrolls sideways.** `main` and the footer clip on the x axis only,
  so a thrown button is cut off rather than widening the document.

The sprites are pixel matrices in `tools/sprites/*.txt`, expanded into
box-shadow CSS by `tools/build-sprites.py` and pasted between the `SPRITES:`
markers in `style.css`. Edit the matrix, not the CSS:

```sh
just sprites   # rewrite the generated block
just check     # includes a check that the block is not stale
```

Under `prefers-reduced-motion` the whole thing stops and the crew becomes a
still tableau perched around an entirely readable page.

## Adding a game

1. Copy one of the three `<li class="card">` blocks in `index.html`.
2. Change the accent class (`card--wages`, `card--pinball`, `card--looplings`)
   to a new one, and add a matching `--accent` rule in `style.css` next to the
   others.
3. Update the count in the `#titles` heading, which is written out in words.

The grid reflows on its own; no other change is needed.

## Where the crest comes from

`assets/logo.png` is derived from `loopback_games.png`, the original square
mark. The circuit-board background is keyed out by luminance and the result is
quantised to 128 colours, which takes it from 910 kB to 18 kB:

```sh
magick loopback_games.png \
  \( +clone -colorspace Gray -level 14%,44% -sigmoidal-contrast 4x50% \) \
  -alpha off -compose CopyOpacity -composite -trim +repage \
  -resize 384x384 -dither None -colors 128 -strip assets/logo.png
```

`assets/og.jpg` is `loopback_games_full.jpeg` cropped to 1200x630.

## Credits

Press Start 2P by CodeMan38, used under the SIL Open Font License 1.1. The
licence travels with the font in `assets/press-start-2p-OFL.txt`.

Everything else is MIT licensed. See [LICENSE](LICENSE).
