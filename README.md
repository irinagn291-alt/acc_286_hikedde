# Heddle

Heddle is a bead diary for people who think in knots on a string. You tie a short caption on today's bead, then string a photo or a voice note so the bead files and the year cloth gains weft. The audience is not looking for a reverse-chronological feed or a random past draw.

## Architecture

A knot is a three-case fold: Loose, Tied, or Strung. The thread is the ordered fold of those knots, rebuilt from marks. Tie writes a KnotMark and folds Loose to Tied. String on Tied writes a StringMark and folds Tied to Strung. String on Loose writes DriftMark and leaves every bead unstrung. A second Tie on the same day writes FullMark until Peel. Peel drops the newest mark and can reopen Tied or return Loose. On this day selects Strung knots that share month and day in earlier years. Cloth density is the Strung count per ISO week. An empty thread is Loose.

The fold fits this product because the home screen is the thread itself. Beads are not rows in a journal table. Each gesture is a mark, and the year cloth and on-this-day lists are derived, never stored.

## Why someone would pick it

Tie, then string. The opening bead is already tied, so the first tap strings a photo or a voice note that stays on the device. One tie per day unless you peel. Prior years line up on this calendar date. The year becomes a cloth of weekly weft.

## Art

Style: high contrast black and white photography, mixed media.

Base prompt: High-contrast black and white photography mixed with cut paper, fiber thread, and a solid photographic bead. Hard tonal separation, visible grain, mixed-media collage, quiet negative space around the subject, no lettering, no glossy glass, no hollow frames.

Image sets are named in SPEC section 13.2 (`hed_AppIcon` through `hed_HeaderDecor`). Pixel art is filled by a later generate step. Prompts for each set are the ones in that section.

## How this differs

This is a persisted tie and string on a vertical bead thread, with a derived year cloth and on-this-day recall. It is not a coverflow catch, a midnight wick, a random draw, a seat and develop flow, or a year-mood canvas.

## Build

```
xcodegen generate
xcodebuild build-for-testing -scheme Heddle -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
```

No Swift packages. System frameworks only.
