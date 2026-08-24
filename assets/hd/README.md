# Upgraded sprites

The cast the page draws in CSS has a second set of portraits behind the
"upgrade" button. These are generated from third-party art, not drawn here.

All three are by **pzUH** and released under **CC0 1.0** (public domain
dedication). CC0 waives attribution, so nothing is owed — this file exists
because the repository should not contain art whose origin is unrecorded.

| file | character | source |
| --- | --- | --- |
| `dino.png` | the cat's counterpart | <https://opengameart.org/content/free-dino-sprites> |
| `zombie.png` | the skeleton's counterpart | <https://opengameart.org/content/the-zombie-free-sprites> |
| `adventurer.png` | the adventurer | <https://opengameart.org/content/adventurer-girl-free-sprite> |

## Regenerating

The source archives are 6–9MB each and are not committed. Download and unpack
them into `hd-src/<name>/` (gitignored), keeping each archive's own layout, then:

    just hd

`tools/build-hd.py` trims each frame to its content, scales it to the height of
the pixel sprite it replaces, and quantises to 128 colours — visually identical
here and about a fifth of the size. It prints the `--cols` each one needs, which
is what `style.css` overrides so the art is not squashed into the pixel
sprite's aspect ratio.
