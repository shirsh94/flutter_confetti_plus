import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../enums/blast_directionality.dart';
import 'confetti_angle.dart';
import 'confetti_emitter.dart';
import 'confetti_position.dart';
import 'confetti_shapes.dart';

/// Default Konfetti-style palette.
const List<Color> kDefaultPartyColors = [
  Color(0xFFFCE18A),
  Color(0xFFFF726D),
  Color(0xFFF4306D),
  Color(0xFFB48DEF),
];

/// Default particle sizes matching Konfetti's SMALL, MEDIUM, and LARGE presets.
const List<Size> kDefaultPartySizes = [
  Size(6, 6),
  Size(8, 8),
  Size(10, 10),
];

/// Configuration for a confetti celebration, modeled after Konfetti's [Party].
class Party {
  const Party({
    this.angle = ConfettiAngle.right,
    this.spread = ConfettiSpread.round,
    this.speed = 30,
    this.maxSpeed = 0,
    this.damping = 0.9,
    this.sizes = kDefaultPartySizes,
    this.colors = kDefaultPartyColors,
    this.shapes = const [ConfettiShape.square, ConfettiShape.circle],
    this.timeToLive = const Duration(milliseconds: 2000),
    this.position = const ConfettiPosition.relative(0.5, 0.5),
    this.delay = Duration.zero,
    required this.emitter,
    this.emojis,
    this.createParticlePath,
  });

  /// Direction in degrees clockwise from the right (0°).
  final int angle;

  /// How wide particles spread around [angle], in degrees (1–360).
  final int spread;

  /// Minimum launch speed.
  final double speed;

  /// Maximum launch speed. When 0, only [speed] is used.
  final double maxSpeed;

  /// Speed decay after launch (0–1). Higher values keep particles moving longer.
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

  Party copyWith({
    int? angle,
    int? spread,
    double? speed,
    double? maxSpeed,
    double? damping,
    List<Size>? sizes,
    List<Color>? colors,
    List<ConfettiShape>? shapes,
    Duration? timeToLive,
    ConfettiPosition? position,
    Duration? delay,
    ConfettiEmitter? emitter,
    List<String>? emojis,
    Path Function(Size size)? createParticlePath,
  }) {
    return Party(
      angle: angle ?? this.angle,
      spread: spread ?? this.spread,
      speed: speed ?? this.speed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      damping: damping ?? this.damping,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      shapes: shapes ?? this.shapes,
      timeToLive: timeToLive ?? this.timeToLive,
      position: position ?? this.position,
      delay: delay ?? this.delay,
      emitter: emitter ?? this.emitter,
      emojis: emojis ?? this.emojis,
      createParticlePath: createParticlePath ?? this.createParticlePath,
    );
  }

  ConfettiBlastDirection get blastDirectionality {
    return spread >= ConfettiSpread.round
        ? ConfettiBlastDirection.explosive
        : ConfettiBlastDirection.directional;
  }

  double get blastDirectionRadians => angle * (3.141592653589793 / 180);

  double get minBlastForce {
    final base = speed <= 0 ? 2.0 : speed / 3;
    return base.clamp(2.0, 100.0).toDouble();
  }

  double get maxBlastForce {
    if (maxSpeed <= 0) {
      return (minBlastForce + 5).clamp(minBlastForce + 1, 100.0).toDouble();
    }
    final max = math.max(maxSpeed, speed) / 3;
    return max.clamp(minBlastForce + 1, 100.0).toDouble();
  }

  double get particleDrag => (1 - damping).clamp(0.0, 1.0).toDouble();

  double get gravity => 0.15;

  Size get minimumSize {
    final widths = sizes.map((size) => size.width);
    final heights = sizes.map((size) => size.height);
    return Size(
      widths.reduce((a, b) => a < b ? a : b),
      heights.reduce((a, b) => a < b ? a : b),
    );
  }

  Size get maximumSize {
    final widths = sizes.map((size) => size.width);
    final heights = sizes.map((size) => size.height);
    return Size(
      widths.reduce((a, b) => a > b ? a : b),
      heights.reduce((a, b) => a > b ? a : b),
    );
  }

  Duration get playbackDuration {
    final emissionEnd = delay + emitter.duration;
    if (emissionEnd >= timeToLive) return emissionEnd;
    return timeToLive;
  }
}

/// Maps a [Party] to low-level widget parameters used by [ConfettiWidget].
class PartyConfiguration {
  const PartyConfiguration({
    required this.alignment,
    required this.position,
    required this.duration,
    required this.delay,
    required this.emissionFrequency,
    required this.numberOfParticles,
    required this.maxBlastForce,
    required this.minBlastForce,
    required this.blastDirectionality,
    required this.blastDirection,
    required this.spreadRadians,
    required this.gravity,
    required this.particleDrag,
    required this.colors,
    required this.emojis,
    required this.minimumSize,
    required this.maximumSize,
    required this.shapes,
    required this.createParticlePath,
  });

  final Alignment alignment;
  final ConfettiPosition position;
  final Duration duration;
  final Duration delay;
  final double emissionFrequency;
  final int numberOfParticles;
  final double maxBlastForce;
  final double minBlastForce;
  final ConfettiBlastDirection blastDirectionality;
  final double blastDirection;
  final double spreadRadians;
  final double gravity;
  final double particleDrag;
  final List<Color> colors;
  final List<String>? emojis;
  final Size minimumSize;
  final Size maximumSize;
  final List<ConfettiShape> shapes;
  final Path Function(Size size)? createParticlePath;

  factory PartyConfiguration.fromParty(Party party) {
    final emission = _resolveEmission(party.emitter);

    return PartyConfiguration(
      alignment: party.position.toAlignment(),
      position: party.position,
      duration: party.playbackDuration,
      delay: party.delay,
      emissionFrequency: emission.frequency,
      numberOfParticles: emission.batchSize,
      maxBlastForce: party.maxBlastForce,
      minBlastForce: party.minBlastForce,
      blastDirectionality: party.blastDirectionality,
      blastDirection: party.blastDirectionRadians,
      spreadRadians: party.spread * (3.141592653589793 / 180),
      gravity: party.gravity,
      particleDrag: party.particleDrag,
      colors: party.colors,
      emojis: party.emojis,
      minimumSize: party.minimumSize,
      maximumSize: party.maximumSize,
      shapes: party.shapes,
      createParticlePath: party.createParticlePath,
    );
  }
}

class _EmissionSettings {
  const _EmissionSettings({
    required this.frequency,
    required this.batchSize,
  });

  final double frequency;
  final int batchSize;
}

_EmissionSettings _resolveEmission(ConfettiEmitter emitter) {
  if (emitter.maxParticles != null) {
    final total = emitter.maxParticles!;
    if (emitter.duration.inMilliseconds <= 250) {
      return _EmissionSettings(
        frequency: 1,
        batchSize: total,
      );
    }

    final batches = (emitter.duration.inMilliseconds / 50).ceil().clamp(1, 20);
    return _EmissionSettings(
      frequency: 1,
      batchSize: (total / batches).ceil().clamp(1, total),
    );
  }

  final rate = emitter.particlesPerSecond!;
  final perFrame = rate / 60;
  return _EmissionSettings(
    frequency: perFrame.clamp(0.01, 1),
    batchSize: math.max(1, perFrame.ceil()),
  );
}
