import 'package:flutter/material.dart';

import '../party/confetti_angle.dart';
import '../party/confetti_emitter.dart';
import '../party/confetti_party.dart';
import '../party/confetti_position.dart';
import '../party/confetti_shapes.dart';

/// A directional confetti launcher preset.
///
/// Cannons are a lightweight convenience layer over [Party]. Use them with
/// `ConfettiPlus.launch` when you want one or more cannon-style blasts without
/// manually building party configurations.
class Cannon {
  const Cannon({
    this.angle = ConfettiAngle.top,
    this.spread = 45,
    this.speed = 35,
    this.maxSpeed = 60,
    this.damping = 0.9,
    this.sizes = kDefaultPartySizes,
    this.colors = kDefaultPartyColors,
    this.shapes = const [ConfettiShape.square, ConfettiShape.circle],
    this.timeToLive = const Duration(milliseconds: 3000),
    this.position = const ConfettiPosition.relative(0.5, 1.0),
    this.delay = Duration.zero,
    this.emitter = const ConfettiEmitter(
      duration: Duration(milliseconds: 100),
      maxParticles: 35,
    ),
    this.emojis,
    this.createParticlePath,
  });

  /// A cannon placed at the bottom-left edge and aimed upward into the screen.
  factory Cannon.left({
    int spread = 45,
    double speed = 35,
    double maxSpeed = 60,
    double damping = 0.9,
    List<Size> sizes = kDefaultPartySizes,
    List<Color> colors = kDefaultPartyColors,
    List<ConfettiShape> shapes = const [
      ConfettiShape.square,
      ConfettiShape.circle,
    ],
    Duration timeToLive = const Duration(milliseconds: 3000),
    Duration delay = Duration.zero,
    ConfettiEmitter emitter = const ConfettiEmitter(
      duration: Duration(milliseconds: 100),
      maxParticles: 35,
    ),
    List<String>? emojis,
    Path Function(Size size)? createParticlePath,
  }) {
    return Cannon(
      angle: ConfettiAngle.top + 45,
      spread: spread,
      speed: speed,
      maxSpeed: maxSpeed,
      damping: damping,
      sizes: sizes,
      colors: colors,
      shapes: shapes,
      timeToLive: timeToLive,
      position: const ConfettiPosition.relative(0.0, 1.0),
      delay: delay,
      emitter: emitter,
      emojis: emojis,
      createParticlePath: createParticlePath,
    );
  }

  /// A cannon placed at the bottom-right edge and aimed upward into the screen.
  factory Cannon.right({
    int spread = 45,
    double speed = 35,
    double maxSpeed = 60,
    double damping = 0.9,
    List<Size> sizes = kDefaultPartySizes,
    List<Color> colors = kDefaultPartyColors,
    List<ConfettiShape> shapes = const [
      ConfettiShape.square,
      ConfettiShape.circle,
    ],
    Duration timeToLive = const Duration(milliseconds: 3000),
    Duration delay = Duration.zero,
    ConfettiEmitter emitter = const ConfettiEmitter(
      duration: Duration(milliseconds: 100),
      maxParticles: 35,
    ),
    List<String>? emojis,
    Path Function(Size size)? createParticlePath,
  }) {
    return Cannon(
      angle: ConfettiAngle.top - 45,
      spread: spread,
      speed: speed,
      maxSpeed: maxSpeed,
      damping: damping,
      sizes: sizes,
      colors: colors,
      shapes: shapes,
      timeToLive: timeToLive,
      position: const ConfettiPosition.relative(1.0, 1.0),
      delay: delay,
      emitter: emitter,
      emojis: emojis,
      createParticlePath: createParticlePath,
    );
  }

  /// A cannon placed at the bottom center and aimed straight upward.
  factory Cannon.center({
    int spread = 45,
    double speed = 35,
    double maxSpeed = 60,
    double damping = 0.9,
    List<Size> sizes = kDefaultPartySizes,
    List<Color> colors = kDefaultPartyColors,
    List<ConfettiShape> shapes = const [
      ConfettiShape.square,
      ConfettiShape.circle,
    ],
    Duration timeToLive = const Duration(milliseconds: 3000),
    Duration delay = Duration.zero,
    ConfettiEmitter emitter = const ConfettiEmitter(
      duration: Duration(milliseconds: 100),
      maxParticles: 35,
    ),
    List<String>? emojis,
    Path Function(Size size)? createParticlePath,
  }) {
    return Cannon(
      spread: spread,
      speed: speed,
      maxSpeed: maxSpeed,
      damping: damping,
      sizes: sizes,
      colors: colors,
      shapes: shapes,
      timeToLive: timeToLive,
      delay: delay,
      emitter: emitter,
      emojis: emojis,
      createParticlePath: createParticlePath,
    );
  }

  /// Direction in degrees clockwise from the right (0°).
  final int angle;

  /// How wide particles spread around [angle], in degrees.
  final int spread;

  /// Minimum launch speed.
  final double speed;

  /// Maximum launch speed.
  final double maxSpeed;

  /// Speed decay after launch (0-1).
  final double damping;

  /// Possible particle sizes; one is picked at random per particle.
  final List<Size> sizes;

  /// Possible particle colors; one is picked at random per particle.
  final List<Color> colors;

  /// Possible particle shapes; one is picked at random per particle.
  final List<ConfettiShape> shapes;

  /// How long particles remain alive before disappearing.
  final Duration timeToLive;

  /// Where particles spawn on the canvas.
  final ConfettiPosition position;

  /// Delay before emission starts.
  final Duration delay;

  /// How many particles to emit and for how long.
  final ConfettiEmitter emitter;

  /// Optional emoji particles instead of colored shapes.
  final List<String>? emojis;

  /// Optional custom path builder that overrides [shapes].
  final Path Function(Size size)? createParticlePath;

  /// Converts this cannon preset into the lower-level [Party] model.
  Party toParty() {
    return Party(
      angle: angle,
      spread: spread,
      speed: speed,
      maxSpeed: maxSpeed,
      damping: damping,
      sizes: sizes,
      colors: colors,
      shapes: shapes,
      timeToLive: timeToLive,
      position: position,
      delay: delay,
      emitter: emitter,
      emojis: emojis,
      createParticlePath: createParticlePath,
    );
  }
}
