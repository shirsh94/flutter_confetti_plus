import 'package:flutter/material.dart';

import 'confetti_angle.dart';
import 'confetti_emitter.dart';
import 'confetti_party.dart';
import 'confetti_position.dart';
import 'confetti_shapes.dart';

export 'confetti_angle.dart';
export 'confetti_emitter.dart';
export 'confetti_party.dart';
export 'confetti_position.dart';
export 'confetti_shapes.dart';

/// Konfetti-style preset configurations.
class PartyPresets {
  const PartyPresets._();

  /// Bursts from the bottom center with mixed spreads, like Konfetti's `festive`.
  static List<Party> festive() {
    final party = Party(
      speed: 30,
      maxSpeed: 50,
      damping: 0.9,
      angle: ConfettiAngle.top,
      spread: 45,
      sizes: const [Size(6, 6), Size(10, 10), Size(10, 10)],
      shapes: const [ConfettiShape.square, ConfettiShape.circle],
      timeToLive: const Duration(milliseconds: 3000),
      colors: kDefaultPartyColors,
      emitter: ConfettiEmitter.burst(max: 30),
      position: const ConfettiPosition.relative(0.5, 1.0),
    );

    return [
      party,
      party.copyWith(
        speed: 55,
        maxSpeed: 65,
        spread: 10,
        emitter: ConfettiEmitter.burst(max: 10),
      ),
      party.copyWith(
        speed: 50,
        maxSpeed: 60,
        spread: 120,
        emitter: ConfettiEmitter.burst(max: 40),
      ),
      party.copyWith(
        speed: 65,
        maxSpeed: 80,
        spread: 10,
        emitter: ConfettiEmitter.burst(max: 10),
      ),
    ];
  }

  /// Explosion from the upper center, like Konfetti's `explode`.
  static List<Party> explode() {
    return [
      Party(
        speed: 0,
        maxSpeed: 30,
        damping: 0.9,
        spread: ConfettiSpread.round,
        colors: kDefaultPartyColors,
        emitter: ConfettiEmitter.burst(max: 100),
        position: const ConfettiPosition.relative(0.5, 0.3),
      ),
    ];
  }

  /// Streams from both sides, like Konfetti's `parade`.
  static List<Party> parade() {
    final party = Party(
      speed: 10,
      maxSpeed: 30,
      damping: 0.9,
      angle: ConfettiAngle.right - 45,
      spread: ConfettiSpread.small,
      colors: kDefaultPartyColors,
      emitter: ConfettiEmitter.continuous(
        duration: const Duration(seconds: 5),
        perSecond: 30,
      ),
      position: const ConfettiPosition.relative(0.0, 0.5),
    );

    return [
      party,
      party.copyWith(
        angle: ConfettiAngle.left + 45,
        position: const ConfettiPosition.relative(1.0, 0.5),
      ),
    ];
  }

  /// Rain from the top edge, like Konfetti's `rain`.
  static List<Party> rain() {
    return [
      Party(
        speed: 0,
        maxSpeed: 15,
        damping: 0.9,
        angle: ConfettiAngle.bottom,
        spread: ConfettiSpread.round,
        colors: kDefaultPartyColors,
        emitter: ConfettiEmitter.continuous(
          duration: const Duration(seconds: 5),
          perSecond: 100,
        ),
        position: ConfettiPosition.between(
          const ConfettiPosition.relative(0.0, 0.0),
          const ConfettiPosition.relative(1.0, 0.0),
        ),
      ),
    ];
  }
}
