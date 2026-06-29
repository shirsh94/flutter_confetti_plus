## 0.0.3

- Added `ConfettiPlus.launch` with `Cannon.left`, `Cannon.right`, and
  `Cannon.center` for multi-cannon overlay blasts.
- Added one-line celebration helpers: `ConfettiPlus.success`,
  `ConfettiPlus.failure`, `ConfettiPlus.levelUp`, and
  `ConfettiPlus.purchase`.
- Added `ConfettiPlus.sequence` and `ConfettiStep` presets for timeline
  animations including burst, fireworks, and rain steps.
- Added `ConfettiMode` and `ConfettiPlus.launchMode` for fireworks, fountain,
  rain, and explosion motion modes.
- Updated README documentation for the new high-level APIs.
- Added widget tests covering cannon launches, celebration helpers, timeline
  sequences, and motion modes.

## 0.0.2

- Highlighted the package feature set more clearly in the README.
- Updated README installation instructions for the latest package version.
- Improved release metadata for pub.dev scoring and repository verification.
- Fixed publish analyzer warnings by cleaning up library naming, constructor
  style, and unnecessary null assertions.

## 0.0.1

- Initial release of `flutter_confetti_plus`.
- Added fire-and-forget overlay launches with `Confetti.show`.
- Added `ConfettiController` and `ConfettiWidget` for managed playback.
- Added emoji particle support.
- Added custom widget sprite particle support.
- Added Konfetti-style `Party` API with festive, explode, parade, and rain presets.
- Added custom particle path support for app-defined shapes.
- Added `ConfettiBlastDirection` for clearer blast direction configuration, with
  deprecated `BlastDirectionality` compatibility alias.
- Added MIT license and expanded README usage documentation.
