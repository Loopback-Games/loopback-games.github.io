#!/usr/bin/env python3
"""Turn the CC0 source art in hd-src/ into the sprites behind the upgrade button.

The page draws its cast from the pixel matrices in tools/sprites/. Pressing
"upgrade" swaps each one for a bitmap of the same character drawn properly.
Those bitmaps are generated here rather than committed by hand, so the
derivation from the original art is reproducible.

The sources are large (20MB+ of zips) and are not in the repository. Fetch them
into hd-src/ first — assets/hd/README.md records where each one comes from.

    just hd            # rewrite assets/hd/*.png
    just hd --check    # fail if they are stale
"""

from __future__ import annotations

import pathlib
import sys

from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "hd-src"
OUT = ROOT / "assets" / "hd"

# Each entry pairs an upgraded bitmap with the pixel sprite it stands in for.
# `rows` is that sprite's matrix height, which the bitmap has to match so the
# character keeps its size on the page and its feet stay on the ground.
CAST = [
    ("dino", "png/Idle (1).png", 13),
    ("zombie", "png/male/Idle (1).png", 16),
    ("adventurer", "png/Idle (1).png", 19),
]
SCALE = 2  # for high-density displays
COLOURS = 128  # indistinguishable from full colour here, and a fifth of the size


def build(name: str, rel: str, rows: int) -> tuple[str, int]:
    src = SRC / name / rel
    if not src.exists():
        raise SystemExit(f"missing {src}\nsee {OUT / 'README.md'} for where to get it")

    art = Image.open(src).convert("RGBA")
    art = art.crop(art.getbbox())  # the frames are padded to a common canvas

    # Height is fixed by the sprite being replaced; width follows the art, so
    # nothing is squashed and the CSS only has to override --cols.
    cols = round(rows * art.width / art.height)
    height = rows * 4 * SCALE  # 4px is --px at its largest
    width = round(art.width * height / art.height)

    out = art.resize((width, height), Image.LANCZOS).quantize(
        colors=COLOURS, method=Image.FASTOCTREE
    )
    OUT.mkdir(parents=True, exist_ok=True)
    out.save(OUT / f"{name}.png", optimize=True)
    return name, cols


def main() -> int:
    if "--check" in sys.argv:
        missing = [n for n, _, _ in CAST if not (OUT / f"{n}.png").exists()]
        if missing:
            print(f"missing upgraded sprites: {', '.join(missing)}", file=sys.stderr)
            return 1
        print("upgraded sprites are present")
        return 0

    total = 0
    for name, rel, rows in CAST:
        n, cols = build(name, rel, rows)
        size = (OUT / f"{n}.png").stat().st_size
        total += size
        print(f"{n:12s} --cols: {cols:2d}   {size / 1024:5.1f}KB")
    print(f"wrote {len(CAST)} sprites, {total / 1024:.0f}KB total")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
