import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_confetti_plus/flutter_confetti_plus.dart';

void main() {
  group('ConfettiController', () {
    test('throws assertion error when `duration` is not positive', () {
      expect(() => ConfettiController(duration: const Duration(days: -20)),
          throwsAssertionError);

      expect(() => ConfettiController(duration: const Duration(seconds: 0)),
          throwsAssertionError);

      expect(
          () => ConfettiController(duration: const Duration(milliseconds: 0)),
          throwsAssertionError);

      expect(
          () => ConfettiController(duration: const Duration(microseconds: 0)),
          throwsAssertionError);
    });
  });

  group('Confetti', () {
    testWidgets('show inserts and removes a confetti overlay', (tester) async {
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (buildContext) {
              context = buildContext;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final future = Confetti.show(
        context,
        duration: const Duration(milliseconds: 10),
        removeAfter: const Duration(milliseconds: 20),
      );

      await tester.pump();

      expect(find.byType(ConfettiWidget), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 20));
      await future;
      await tester.pump();

      expect(find.byType(ConfettiWidget), findsNothing);
    });

    testWidgets('show supports emoji particles', (tester) async {
      late BuildContext context;
      const emojis = ['🎉', '🔥', '🚀', '💰', '👨‍💻'];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (buildContext) {
              context = buildContext;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final future = Confetti.show(
        context,
        emojis: emojis,
        duration: const Duration(milliseconds: 10),
        removeAfter: const Duration(milliseconds: 20),
      );

      await tester.pump();

      final widget = tester.widget<ConfettiWidget>(find.byType(ConfettiWidget));
      expect(widget.emojis, emojis);

      await tester.pump(const Duration(milliseconds: 20));
      await future;
    });

    testWidgets('show supports widget sprites', (tester) async {
      late BuildContext context;
      final sprites = [
        Container(color: Colors.red, width: 24, height: 24),
        Container(color: Colors.blue, width: 18, height: 18),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (buildContext) {
              context = buildContext;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final future = Confetti.show(
        context,
        widgetSprites: sprites,
        duration: const Duration(milliseconds: 10),
        removeAfter: const Duration(milliseconds: 20),
      );

      await tester.pump();

      final widget = tester.widget<ConfettiWidget>(find.byType(ConfettiWidget));
      expect(widget.widgetSprites, sprites);

      await tester.pump(const Duration(milliseconds: 20));
      await future;
    });

    testWidgets('launchParties inserts party confetti overlays',
        (tester) async {
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (buildContext) {
              context = buildContext;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final future = Confetti.launchParties(
        context,
        PartyPresets.explode(),
        removeAfter: const Duration(milliseconds: 20),
      );

      await tester.pump();

      expect(find.byType(ConfettiWidget), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 20));
      await future;
      await tester.pump();

      expect(find.byType(ConfettiWidget), findsNothing);
    });

    test('PartyConfiguration maps Konfetti-style settings', () {
      final config = PartyConfiguration.fromParty(
        Party(
          angle: ConfettiAngle.top,
          spread: 45,
          speed: 30,
          maxSpeed: 50,
          emitter: ConfettiEmitter.burst(max: 30),
          position: const ConfettiPosition.relative(0.5, 1.0),
        ),
      );

      expect(config.blastDirectionality, ConfettiBlastDirection.directional);
      expect(config.numberOfParticles, 30);
      expect(config.alignment, Alignment.bottomCenter);
    });
  });
}
