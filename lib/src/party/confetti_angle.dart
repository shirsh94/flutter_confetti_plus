/// Direction constants for [Party] angle, matching Konfetti conventions.
///
/// Angles are in degrees clockwise from the right (0°).
class ConfettiAngle {
  const ConfettiAngle._();

  static const int top = 270;
  static const int right = 0;
  static const int bottom = 90;
  static const int left = 180;
}

/// Spread presets for [Party], in degrees.
class ConfettiSpread {
  const ConfettiSpread._();

  static const int small = 30;
  static const int wide = 100;
  static const int round = 360;
}
