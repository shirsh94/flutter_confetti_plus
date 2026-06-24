import 'dart:math';

import 'package:flutter/material.dart';

/// Built-in particle shapes, similar to Konfetti's `Shape` presets.
enum ConfettiShape {
  square,
  circle,
}

Path confettiShapePath(ConfettiShape shape, Size size) {
  switch (shape) {
    case ConfettiShape.square:
      return _rectanglePath(size);
    case ConfettiShape.circle:
      return _circlePath(size);
  }
}

Path Function(Size size) randomConfettiShapePath(
  List<ConfettiShape> shapes,
  Random random,
) {
  final shape = shapes[random.nextInt(shapes.length)];
  return (Size size) => confettiShapePath(shape, size);
}

Path _rectanglePath(Size size) {
  return Path()
    ..moveTo(0, 0)
    ..lineTo(-size.width, 0)
    ..lineTo(-size.width, size.height)
    ..lineTo(0, size.height)
    ..close();
}

Path _circlePath(Size size) {
  final radius = min(size.width, size.height) / 2;
  return Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: radius));
}
