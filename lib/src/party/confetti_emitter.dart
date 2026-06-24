/// Controls how many confetti particles are emitted and for how long.
///
/// Mirrors Konfetti's `Emitter` configuration with burst and continuous modes.
class ConfettiEmitter {
  const ConfettiEmitter({
    required this.duration,
    this.maxParticles,
    this.particlesPerSecond,
  }) : assert(
          maxParticles != null || particlesPerSecond != null,
          'Provide either maxParticles or particlesPerSecond.',
        ),
        assert(
          maxParticles == null || maxParticles > 0,
          'maxParticles must be greater than zero.',
        ),
        assert(
          particlesPerSecond == null || particlesPerSecond > 0,
          'particlesPerSecond must be greater than zero.',
        );

  /// Total duration of the emission window.
  final Duration duration;

  /// Emit up to this many particles over [duration] (burst mode).
  final int? maxParticles;

  /// Emit this many particles per second over [duration] (continuous mode).
  final double? particlesPerSecond;

  /// Burst a fixed number of particles over a short window.
  factory ConfettiEmitter.burst({
    Duration duration = const Duration(milliseconds: 100),
    int max = 30,
  }) {
    return ConfettiEmitter(
      duration: duration,
      maxParticles: max,
    );
  }

  /// Emit particles continuously at a fixed rate.
  factory ConfettiEmitter.continuous({
    Duration duration = const Duration(seconds: 5),
    double perSecond = 30,
  }) {
    return ConfettiEmitter(
      duration: duration,
      particlesPerSecond: perSecond,
    );
  }
}
