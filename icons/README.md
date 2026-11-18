# Demo icon set (original artwork)

Eight original placeholder app tiles for demo mode, simulator screenshots and App Store imagery. They are abstract shapes in the app's own donut palette and represent no real product. On a real iPhone the app shows each chosen app's genuine icon through `Label(token)`; these tiles are used only where no token exists.

## Three finishes

| Finish | What it is | Use |
| --- | --- | --- |
| `solid` | Rounded tile filled with the palette colour, dark glyph | Default tile on dark and light grounds |
| `glass` | Translucent tile (18% fill, soft edge), glyph in the palette colour | Over cards, photos or coloured backgrounds |
| `glyph` | Glyph only on a fully transparent background | Inline with text, legends, small dots |

## The eight tiles

| No. | Shape | Colour | Palette index | Asset names |
| --- | --- | --- | --- | --- |
| 01 | wave | Teal `#26C6C6` | 0 | `DemoIcon01Solid`, `DemoIcon01Glass`, `DemoIcon01Glyph` |
| 02 | dots | Pink `#F0569A` | 1 | `DemoIcon02Solid`, `DemoIcon02Glass`, `DemoIcon02Glyph` |
| 03 | bars | Blue `#4C8DFF` | 2 | `DemoIcon03Solid`, `DemoIcon03Glass`, `DemoIcon03Glyph` |
| 04 | diamond | Violet `#A47BFF` | 3 | `DemoIcon04Solid`, `DemoIcon04Glass`, `DemoIcon04Glyph` |
| 05 | chevrons | Silver `#C9D2E0` | 4 | `DemoIcon05Solid`, `DemoIcon05Glass`, `DemoIcon05Glyph` |
| 06 | hexagon | Sky `#7FD4FF` | 5 | `DemoIcon06Solid`, `DemoIcon06Glass`, `DemoIcon06Glyph` |
| 07 | steps | Orchid `#D873F5` | 6 | `DemoIcon07Solid`, `DemoIcon07Glass`, `DemoIcon07Glyph` |
| 08 | halfmoon | Slate `#8B95A7` | 7 | `DemoIcon08Solid`, `DemoIcon08Glass`, `DemoIcon08Glyph` |

A demo app at position *n* in the list uses the tile whose palette index is *n* mod 8, the same rule as the donut colours, so a row's tile always matches its donut segment.

## Files

- `svg/` — vector masters, 1024 × 1024 canvas, corner radius 230 (22.5%).
- `png/solid`, `png/glass`, `png/glyph` — PNG with alpha at 128 and 1024 px.
- `preview.png` — all 24 on dark and light grounds.

The silver tile's `glass` and `glyph` finishes are faint on a white ground; use `solid` there.

## Adding them to the app (for the builder)

Create `App/Demo/DemoIcons.xcassets` with one image set per SVG, named as in the table, each holding the SVG with `"preserves-vector-representation": true`, and add the catalogue to the app target in `project.yml`. One vector file then serves every size and scale.

## Using them in demo mode

```swift
Image("DemoIcon01Solid")
    .resizable()
    .frame(width: 36, height: 36)   // iOS clips nothing; the tile's corners are in the artwork
```

Keep them inside `#if DEBUG` paths and screenshot builds. The release app has no need of them at run time.
