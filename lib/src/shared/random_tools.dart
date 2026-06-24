import 'dart:math' show Random;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

final _random = Random();

abstract class RandomTools {
  static double between(double min, double max) {
    return lerpDouble(min, max, _random.nextDouble())!;
  }

  static Color materialColor() {
    return Colors.primaries[_random.nextInt(Colors.primaries.length)];
  }

  static bool coinFlip() => _random.nextBool();
}
