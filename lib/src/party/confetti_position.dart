import 'dart:math';

import 'package:flutter/material.dart';

/// Where confetti should spawn on the canvas.
///
/// Use [ConfettiPosition.relative] for coordinates between 0.0 and 1.0,
/// or chain [ConfettiPosition.between] to randomize within a range.
abstract class ConfettiPosition {
  const ConfettiPosition();

  /// Spawn at a fixed relative position (0.0–1.0 on each axis).
  const factory ConfettiPosition.relative(double x, double y) =
      ConfettiRelativePosition;

  /// Spawn at a fixed absolute pixel position.
  const factory ConfettiPosition.absolute(double x, double y) =
      ConfettiAbsolutePosition;

  /// Randomize spawn position between two relative points.
  factory ConfettiPosition.between(
    ConfettiPosition start,
    ConfettiPosition end,
  ) {
    return ConfettiBetweenPosition(min: start, max: end);
  }

  /// Converts a relative position to Flutter [Alignment].
  Alignment toAlignment();

  /// Resolves a random spawn offset in pixels for the given canvas size.
  Offset resolveOffset(Size canvasSize, Random random);
}

class ConfettiRelativePosition extends ConfettiPosition {
  const ConfettiRelativePosition(this.x, this.y);

  final double x;
  final double y;

  @override
  Alignment toAlignment() => Alignment(x * 2 - 1, y * 2 - 1);

  @override
  Offset resolveOffset(Size canvasSize, Random random) {
    return Offset(x * canvasSize.width, y * canvasSize.height);
  }
}

class ConfettiAbsolutePosition extends ConfettiPosition {
  const ConfettiAbsolutePosition(this.x, this.y);

  final double x;
  final double y;

  @override
  Alignment toAlignment() {
    throw UnsupportedError(
      'Absolute positions are resolved per canvas size at launch time.',
    );
  }

  @override
  Offset resolveOffset(Size canvasSize, Random random) => Offset(x, y);
}

class ConfettiBetweenPosition extends ConfettiPosition {
  const ConfettiBetweenPosition({
    required this.min,
    required this.max,
  });

  final ConfettiPosition min;
  final ConfettiPosition max;

  @override
  Alignment toAlignment() {
    if (min is ConfettiRelativePosition && max is ConfettiRelativePosition) {
      final start = min as ConfettiRelativePosition;
      final end = max as ConfettiRelativePosition;
      final centerX = (start.x + end.x) / 2;
      final centerY = (start.y + end.y) / 2;
      return Alignment(centerX * 2 - 1, centerY * 2 - 1);
    }
    return Alignment.center;
  }

  @override
  Offset resolveOffset(Size canvasSize, Random random) {
    final start = min.resolveOffset(canvasSize, random);
    final end = max.resolveOffset(canvasSize, random);
    return Offset(
      _lerp(start.dx, end.dx, random.nextDouble()),
      _lerp(start.dy, end.dy, random.nextDouble()),
    );
  }
}

double _lerp(double start, double end, double t) => start + (end - start) * t;
