# MalaWatch

iPhone-first mala / prayer beads counter with a future Apple Watch companion.

## Product Shape

MalaWatch is a quiet daily ritual app for counting mala beads, mantras, prayers,
affirmations, or breath cycles. The iPhone app is the primary MVP because it is faster to build, easier to share, and simpler to test across Chinese, US, and Indian audiences. The Apple Watch app remains a natural companion once the core ritual feels right.

## MVP

- Count with a large tactile tap target on iPhone.
- Support 27, 54, and 108 bead goals.
- Give gentle haptic feedback on each bead and stronger feedback at completion.
- Show today's current count, progress, and completed rounds.
- Let users customize the label and visual theme.
- Keep all data local in the first version.

## Positioning

Primary English phrasing:

- App name direction: MalaWatch, Daily Mala, 108 Mala, StillMala
- Category phrase: Prayer Beads Counter
- Keywords: mala, prayer beads, japa mala, mantra counter, meditation counter,
  Buddhist beads, 108 beads, mindfulness, chant counter

Chinese phrasing:

- 佛珠
- 念珠
- 數珠
- 念佛
- 持咒
- 冥想
- 計數器

## Project Layout

This folder currently contains the product source scaffold:

- `Shared/`: shared app model and defaults.
- `MalaWatch iOS App/`: primary iPhone SwiftUI experience.
- `MalaWatch Watch App/`: Apple Watch companion experiment.
- `PRODUCT.md`: product decisions, market notes, and next steps.

`project.yml`: XcodeGen config for generating an Xcode project.

## Generate The Xcode Project

If XcodeGen is installed:

```sh
xcodegen generate
open MalaWatch.xcodeproj
```

If XcodeGen is not installed yet:

```sh
brew install xcodegen
```

The source files can also be attached manually to a new Xcode iOS App + watchOS
App project.
