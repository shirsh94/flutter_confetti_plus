import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_confetti_plus/flutter_confetti_plus.dart';

void main() {
  group('ConfettiController', () {
    test('starts stopped', () {
      final controller = ConfettiController();
      addTearDown(controller.dispose);

      expect(controller.state, ConfettiControllerState.stopped);
    });

    test('throws assertion error when duration is not positive', () {
      expect(
        () => ConfettiController(duration: const Duration(days: -20)),
        throwsAssertionError,
      );
      expect(
        () => ConfettiController(duration: Duration.zero),
        throwsAssertionError,
      );
    });

    test('notifies listeners when playing and stopping', () {
      final controller = ConfettiController();
      addTearDown(controller.dispose);
      final states = <ConfettiControllerState>[];

      controller.addListener(() {
        states.add(controller.state);
      });

      controller.play();
      controller.stop();
      controller.stop(clearAllParticles: true);

      expect(
        states,
        [
          ConfettiControllerState.playing,
          ConfettiControllerState.stopped,
          ConfettiControllerState.stoppedAndCleared,
        ],
      );
    });

    test('does not stop after dispose', () {
      final controller = ConfettiController();

      controller.dispose();
      controller.stop();

      expect(controller.state, ConfettiControllerState.disposed);
    });
  });
}
