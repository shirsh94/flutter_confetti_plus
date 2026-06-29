import 'package:flutter/material.dart';

import '../party/party_presets.dart';

/// One step in a [ConfettiPlus.sequence] timeline.
class ConfettiStep {
  const ConfettiStep({
    required this.parties,
    this.removeAfter,
    this.delayAfter = Duration.zero,
  });

  /// The party configurations launched together for this step.
  final List<Party> parties;

  /// When this step's overlay should be removed.
  final Duration? removeAfter;

  /// Extra pause before the next step starts.
  final Duration delayAfter;

  /// A quick center burst.
  factory ConfettiStep.burst({
    List<Color> colors = kDefaultPartyColors,
    int particles = 50,
    Duration? removeAfter,
    Duration delayAfter = const Duration(milliseconds: 120),
  }) {
    return ConfettiStep(
      parties: [
        Party(
          speed: 0,
          maxSpeed: 34,
          damping: 0.9,
          spread: ConfettiSpread.round,
          colors: colors,
          emitter: ConfettiEmitter.burst(max: particles),
          position: const ConfettiPosition.relative(0.5, 0.35),
        ),
      ],
      removeAfter: removeAfter,
      delayAfter: delayAfter,
    );
  }

  /// Staggered bursts from the lower left and right, like fireworks.
  factory ConfettiStep.fireworks({
    List<Color> colors = kDefaultPartyColors,
    int particlesPerSide = 36,
    Duration? removeAfter,
    Duration delayAfter = const Duration(milliseconds: 120),
  }) {
    final left = Party(
      angle: ConfettiAngle.top + 35,
      spread: 50,
      speed: 42,
      maxSpeed: 72,
      damping: 0.9,
      colors: colors,
      shapes: const [ConfettiShape.square, ConfettiShape.circle],
      emitter: ConfettiEmitter.burst(max: particlesPerSide),
      position: const ConfettiPosition.relative(0.15, 1.0),
    );

    return ConfettiStep(
      parties: [
        left,
        left.copyWith(
          angle: ConfettiAngle.top - 35,
          delay: const Duration(milliseconds: 120),
          position: const ConfettiPosition.relative(0.85, 1.0),
        ),
      ],
      removeAfter: removeAfter,
      delayAfter: delayAfter,
    );
  }

  /// A falling confetti rain step.
  factory ConfettiStep.rain({
    List<Color> colors = kDefaultPartyColors,
    Duration duration = const Duration(seconds: 2),
    double perSecond = 80,
    Duration? removeAfter,
    Duration delayAfter = Duration.zero,
  }) {
    return ConfettiStep(
      parties: [
        PartyPresets.rain().first.copyWith(
          colors: colors,
          emitter: ConfettiEmitter.continuous(
            duration: duration,
            perSecond: perSecond,
          ),
        ),
      ],
      removeAfter: removeAfter,
      delayAfter: delayAfter,
    );
  }
}
