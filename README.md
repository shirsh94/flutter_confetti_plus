flutter_confetti_plus
=====================

A Flutter confetti package for quick celebration overlays, fully controlled
confetti widgets, emoji particles, custom widget sprites, and Konfetti-style
party presets.

Use it for success states, rewards, onboarding moments, game wins, payment
confirmations, or any moment that deserves a little motion without building a
particle system from scratch.

<p align="center">
	<img src="https://github.com/shirsh94/flutter_confetti_plus/blob/main/demo/confetti.gif?raw=true"/>
</p>


## Features

- One-line overlay launches with `Confetti.show(context)`.
- Controller-based playback with `ConfettiController` and `ConfettiWidget`.
- Emoji particles with any emoji supported by the platform font.
- Custom widget sprite particles for branded chips, badges, icons, or tokens.
- Konfetti-style `Party` API with built-in `festive`, `explode`, `parade`, and
  `rain` presets.
- Custom particle paths for stars, hearts, triangles, or app-specific shapes.
- Tunable gravity, drag, blast direction, particle count, size, color, stroke,
  and canvas bounds.
- Optional frame-rate protection that pauses emission on slow frames.

## Installation

Add the package to your app:

```yaml
dependencies:
  flutter_confetti_plus: ^0.0.1
```

Then import it:

```dart
import 'package:flutter_confetti_plus/flutter_confetti_plus.dart';
```

## Quick Start

The fastest way to celebrate is `Confetti.show`. It inserts an overlay, starts a
temporary controller, plays the animation, and removes itself automatically.

```dart
ElevatedButton(
  onPressed: () {
    Confetti.show(context);
  },
  child: const Text('Celebrate'),
);
```

Tune the burst inline:

```dart
Confetti.show(
  context,
  alignment: Alignment.topCenter,
  numberOfParticles: 40,
  emissionFrequency: 0.05,
  minBlastForce: 8,
  maxBlastForce: 28,
  gravity: 0.25,
  colors: const [
    Color(0xFF2DD4BF),
    Color(0xFFF97316),
    Color(0xFF6366F1),
  ],
);
```

Use `rootOverlay: true` when the confetti should appear above nested navigators,
dialogs, or tab shells:

```dart
Confetti.show(
  context,
  rootOverlay: true,
);
```

## Overlay API

Use the overlay API when you want a short, fire-and-forget effect.

```dart
await Confetti.show(
  context,
  duration: const Duration(seconds: 1),
  removeAfter: const Duration(seconds: 3),
  alignment: Alignment.center,
  blastDirectionality: ConfettiBlastDirection.explosive,
  numberOfParticles: 30,
);
```

Important overlay parameters:

- `duration`: how long the controller emits particles.
- `removeAfter`: when the overlay entry is removed. Defaults to twice the
  playback duration so existing particles can finish falling.
- `alignment`: where the emitter sits in the overlay.
- `rootOverlay`: whether to use the app root overlay.
- `shouldLoop`: repeats emission until the overlay is removed.

## Controller-Based Usage

Use `ConfettiWidget` when the confetti should live in your widget tree or when
you need explicit play, stop, clear, and lifecycle control.

```dart
class RewardView extends StatefulWidget {
  const RewardView({super.key});

  @override
  State<RewardView> createState() => _RewardViewState();
}

class _RewardViewState extends State<RewardView> {
  late final ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ConfettiWidget(
          confettiController: _controller,
          blastDirectionality: ConfettiBlastDirection.explosive,
          shouldLoop: false,
          numberOfParticles: 25,
          colors: const [Colors.green, Colors.blue, Colors.pink],
          child: ElevatedButton(
            onPressed: _controller.play,
            child: const Text('Claim reward'),
          ),
        ),
      ],
    );
  }
}
```

Stop emission and let active particles fall:

```dart
_controller.stop();
```

Stop and clear all visible particles immediately:

```dart
_controller.stop(clearAllParticles: true);
```

Track particle counts for debugging or performance UI:

```dart
final controller = ConfettiController(
  particleStatsCallback: (stats) {
    debugPrint(
      'active: ${stats.activeNumberOfParticles}, total: ${stats.numberOfParticles}',
    );
  },
);
```

## Direction And Placement

For random bursts in every direction:

```dart
Confetti.show(
  context,
  blastDirectionality: ConfettiBlastDirection.explosive,
);
```

For a cannon-style directional blast, use radians:

```dart
Confetti.show(
  context,
  alignment: Alignment.bottomCenter,
  blastDirectionality: ConfettiBlastDirection.directional,
  blastDirection: -pi / 2,
);
```

Common directions:

- `0`: right.
- `pi / 2`: down.
- `pi`: left.
- `-pi / 2`: up.

Import `dart:math` when using `pi`.

## Emoji Confetti

Pass `emojis` to render text particles instead of colored shapes:

```dart
Confetti.show(
  context,
  emojis: const ['🎉', '🔥', '🚀', '💰'],
  numberOfParticles: 30,
  minimumSize: const Size(24, 24),
  maximumSize: const Size(46, 46),
  gravity: 0.25,
);
```

Any non-empty string can be used. Platform emoji rendering depends on the
device font, so complex multi-codepoint emoji can look slightly different across
iOS, Android, web, and desktop.

## Widget Sprite Confetti

Pass `widgetSprites` to turn Flutter widgets into particle images. This is good
for branded badges, product icons, chips, game items, avatars, or reward tokens.

```dart
Confetti.show(
  context,
  widgetSprites: const [
    Chip(label: Text('XP')),
    Chip(label: Text('+10')),
    Icon(Icons.star, color: Colors.amber),
  ],
  numberOfParticles: 24,
  minimumSize: const Size(28, 28),
  maximumSize: const Size(54, 54),
);
```

The package captures each widget sprite to an image before launching particles.
Keep sprite widgets small and visually self-contained for best results.

## Party Presets

The `Party` API is modeled after Konfetti. It is useful when you want named
celebration styles or multiple emitters at once.

```dart
Confetti.launchParties(
  context,
  PartyPresets.festive(),
);
```

Built-in presets:

- `PartyPresets.festive()`: layered upward celebration from the bottom center.
- `PartyPresets.explode()`: round burst near the upper center.
- `PartyPresets.parade()`: continuous streams from the left and right edges.
- `PartyPresets.rain()`: continuous rain from the top edge.

Launch a single custom party:

```dart
Confetti.launchParty(
  context,
  Party(
    angle: ConfettiAngle.top,
    spread: 60,
    speed: 35,
    maxSpeed: 60,
    damping: 0.9,
    colors: const [Colors.red, Colors.yellow, Colors.blue],
    position: const ConfettiPosition.relative(0.5, 1.0),
    emitter: ConfettiEmitter.burst(max: 50),
  ),
);
```

Launch two side cannons:

```dart
Confetti.launchParties(
  context,
  [
    Party(
      angle: ConfettiAngle.right - 35,
      spread: ConfettiSpread.small,
      position: const ConfettiPosition.relative(0.0, 0.8),
      emitter: ConfettiEmitter.burst(max: 35),
    ),
    Party(
      angle: ConfettiAngle.left + 35,
      spread: ConfettiSpread.small,
      position: const ConfettiPosition.relative(1.0, 0.8),
      emitter: ConfettiEmitter.burst(max: 35),
    ),
  ],
);
```

## Continuous Emitters

Use `ConfettiEmitter.continuous` for streams:

```dart
Confetti.launchParty(
  context,
  Party(
    angle: ConfettiAngle.bottom,
    spread: ConfettiSpread.round,
    position: ConfettiPosition.between(
      const ConfettiPosition.relative(0.0, 0.0),
      const ConfettiPosition.relative(1.0, 0.0),
    ),
    emitter: ConfettiEmitter.continuous(
      duration: const Duration(seconds: 4),
      perSecond: 80,
    ),
  ),
);
```

Use continuous emitters carefully on low-powered devices. Start with a lower
`perSecond` value and increase only when the animation still feels smooth.

## Custom Shapes

Use `createParticlePath` when the built-in square and circle shapes are not
enough. The callback receives the particle size and returns a Flutter `Path`.

```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_confetti_plus/flutter_confetti_plus.dart';

Path drawStar(Size size) {
  double degToRad(double deg) => deg * (pi / 180.0);

  const points = 5;
  final halfWidth = size.width / 2;
  final outerRadius = halfWidth;
  final innerRadius = halfWidth / 2.5;
  final step = degToRad(360 / points);
  final halfStep = step / 2;
  final path = Path()..moveTo(size.width, halfWidth);

  for (double angle = 0; angle < degToRad(360); angle += step) {
    path
      ..lineTo(
        halfWidth + outerRadius * cos(angle),
        halfWidth + outerRadius * sin(angle),
      )
      ..lineTo(
        halfWidth + innerRadius * cos(angle + halfStep),
        halfWidth + innerRadius * sin(angle + halfStep),
      );
  }

  return path..close();
}
```

Then pass it to either API:

```dart
Confetti.show(
  context,
  createParticlePath: drawStar,
  colors: const [Colors.amber, Colors.orange, Colors.white],
);
```

## Main Options

| Option | Applies to | What it does |
| --- | --- | --- |
| `alignment` | `Confetti.show` | Places the overlay emitter. |
| `confettiController` | `ConfettiWidget` | Controls play, stop, clear, and duration. |
| `duration` | `Confetti.show`, `ConfettiController` | Controls the emission/playback window. |
| `emissionFrequency` | Both | Higher values emit more often. Range: `0` to `1`. |
| `numberOfParticles` | Both | Number of particles emitted per burst. |
| `blastDirectionality` | Both | `explosive` for all directions, `directional` for a cannon. |
| `blastDirection` | Both | Direction in radians when using directional mode. |
| `spreadRadians` | `ConfettiWidget` | Directional spread around `blastDirection`. |
| `minBlastForce` / `maxBlastForce` | Both | Initial particle speed range. |
| `gravity` | Both | Fall speed. Range: `0` to `1`. |
| `particleDrag` | Both | Air resistance. Higher values slow particles sooner. |
| `colors` | Both | Shape particle colors. |
| `emojis` | Both, `Party` | Uses emoji text particles. |
| `widgetSprites` | Both | Uses rendered Flutter widgets as particles. |
| `minimumSize` / `maximumSize` | Both | Particle size range. |
| `strokeWidth` / `strokeColor` | Both | Adds an outline to shape particles. |
| `canvas` | Both | Overrides the drawing area size. |
| `displayTarget` | Both | Shows the emitter target for debugging. |
| `pauseEmissionOnLowFrameRate` | Both | Temporarily pauses emission on slow frames. |
| `createParticlePath` | Both, `Party` | Provides a custom particle shape. |

## Party Options

| Option | What it does |
| --- | --- |
| `angle` | Direction in degrees clockwise from the right. |
| `spread` | Width of the particle cone in degrees. |
| `speed` / `maxSpeed` | Minimum and maximum launch speed. |
| `damping` | Speed decay. Higher values keep particles moving longer. |
| `sizes` | Possible particle sizes. |
| `colors` | Possible particle colors. |
| `shapes` | Built-in `ConfettiShape.square` and `ConfettiShape.circle`. |
| `timeToLive` | How long particles stay alive. |
| `position` | Spawn point, using relative, absolute, or randomized positions. |
| `delay` | Wait time before emission starts. |
| `emitter` | Burst or continuous particle emission. |
| `emojis` | Optional emoji particles. |
| `createParticlePath` | Optional custom path that overrides built-in shapes. |

## Running The Example

The repository includes a full example app with controller demos, party presets,
emoji particles, and widget sprites.

```bash
cd example
flutter run
```

To run on Chrome:

```bash
flutter run -d chrome
```

## Performance Tips

- Start with modest particle counts and increase only where the effect needs it.
- Prefer short overlay bursts for common UI interactions.
- Keep widget sprites small because they are captured before launch.
- Use `pauseEmissionOnLowFrameRate: true` for user-facing effects.
- Avoid several continuous high-rate emitters at the same time on older devices.
- Use `stop(clearAllParticles: true)` when leaving a screen that owns a
  `ConfettiWidget`.

## Choosing The Right API

Use `Confetti.show` when you need a quick overlay and do not care about keeping
state.

Use `ConfettiWidget` and `ConfettiController` when the confetti belongs to a
screen, should wrap a child widget, or needs explicit start and stop behavior.

Use `Party` and `PartyPresets` when you want reusable celebration recipes,
multiple emitters, or Konfetti-style configuration.
