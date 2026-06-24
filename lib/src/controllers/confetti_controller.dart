import 'package:flutter/foundation.dart';

import '../enums/confetti_controller_state.dart';
import '../particle_stats.dart';

/// {@template particle_stats_callback}
/// This callback provides [ParticleStats] as an argument.
/// {@endtemplate}
typedef ParticleStatsCallback = void Function(ParticleStats stats);

class ConfettiController extends ChangeNotifier {
  ConfettiController({
    this.duration = const Duration(seconds: 30),
    this.particleStatsCallback,
  }) : assert(!duration.isNegative && duration.inMicroseconds > 0);

  Duration duration;

  ConfettiControllerState _state = ConfettiControllerState.stopped;

  /// {@macro confetti_controller_state}
  ConfettiControllerState get state => _state;

  /// {@macro particle_stats_callback}
  final ParticleStatsCallback? particleStatsCallback;

  void play() {
    _state = ConfettiControllerState.playing;
    notifyListeners();
  }

  void stop({bool clearAllParticles = false}) {
    if (_state == ConfettiControllerState.disposed) return;

    _state = clearAllParticles
        ? ConfettiControllerState.stoppedAndCleared
        : ConfettiControllerState.stopped;
    notifyListeners();
  }

  @override
  void dispose() {
    _state = ConfettiControllerState.disposed;
    notifyListeners();
    super.dispose();
  }
}
