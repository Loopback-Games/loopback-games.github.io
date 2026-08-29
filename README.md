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

One file pins every tool and one file holds every command.

```sh
mise install   # node, python, just and the linters, at the pinned versions
just setup     # the above, plus the dependencies and the test browser
just           # list the recipes
```

```sh
just run       # http://127.0.0.1:8765
just fmt       # format the page
just lint      # zero-JS guard, generated assets, workflows, formatting
just test      # WCAG 2 AA on both pages, through axe inside Playwright
just markup    # the W3C Nu Html Checker, in a container
just security  # advisories against the dependencies, secrets in the history
just check     # every gate
just ci        # what CI's main job runs
```

Tool versions live in `mise.toml` and nowhere else. `.github/workflows/ci.yml`
installs that same file with `jdx/mise-action` and runs `just ci`, so a workflow
cannot carry a command you are unable to run yourself. It used to carry five
jobs and call the justfile from none of them.

Without `just`, `python3 -m http.server 8765` still serves the page.

## The crew

Twelve of them, loose on the page, no two alike: a cat, a slime, two skeletons,
a knight, a wizard, a noir type in a hat, a blob, a ball — plus a helmet, a
sword and a magic bolt that are not attached to anyone for long.

| Who      | Where        | What they get up to                                                                |
| -------- | ------------ | ---------------------------------------------------------------------------------- |
| Cat      | The wordmark | Pounces along the letters, which flinch under it, then sits down and washes        |
| Slime    | The hero     | Bounces across, misjudges one, lands flat and needs a moment                       |
| Skeleton | The heading  | Drags the word "playable" out of the sentence and drops it                         |
| Knight   | Lost Wages   | Wrenches the `Play` button out of the card and hurls it — **his helmet comes off** |
| Blob     | Pinball      | Rides the card's right frame down like a banister, sideways                        |
| Ball     | Looplings    | Rolls the card's length and shoulders it out of true                               |
| Wizard   | Footer rule  | **Fires a bolt** down the rule                                                     |
| Skeleton | Footer rule  | Takes the bolt, folds up, reassembles, comes back for more                         |
| Hat guy  | Footer rule  | **Throws a sword** the other way                                                   |

Nobody shares a clock. The periods are **7, 11, 13, 17, 19, 23, 29 and 31
seconds** — coprime, so the combination on screen takes over four million
seconds to come round again. There is no sequence to sit through and no loop
point to notice.

Each character is anchored **inside** the element it torments — the thief is a
child of the `<span>` around the word, the helmet tracks the head it sits on —
so wherever the layout puts that element, its resident goes too. Contact is
exact from 360px to 2560px without one hard-coded coordinate.

Three properties the page has to keep, and the tests that hold it to them:

- **Nothing is clickable that should not be.** The crew is `pointer-events:
none` and `aria-hidden`; a sweep of 63 moments at six widths confirms no crew
  element ever captures a point. The `Play` elements were already decorative
  spans — the whole card is the link — so throwing one breaks no control.
- **Nothing moves the layout.** Every antic is `translate`, `rotate` or
  `scale`. The card's shove uses `rotate` alone so it never fights the hover
  `translate`.
- **Nothing scrolls sideways.** `main` and the footer clip on the x axis only.

### Why the art is hand-drawn

Asset packs from sites like CraftPix are tempting and wrong for this repo. Their
freebie licence forbids redistributing the source files "in a manner that would
make some or all of the art files useable to another end user" — which is
precisely what a public repo serving raw files over Pages does. It would also
mislabel their art as MIT. So the cast is drawn here, as pixel matrices in
`tools/sprites/*.txt`, expanded into box-shadow CSS by
`tools/build-sprites.py` and pasted between the `SPRITES:` markers in
`style.css`. Edit the matrix, not the CSS:

```sh
just sprites   # rewrite the generated block
just check     # includes a check that the block is not stale
```

That staleness check is not ceremony: it has already caught a search-and-replace
that reached into the generated block and moved a pixel of the cat.

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
