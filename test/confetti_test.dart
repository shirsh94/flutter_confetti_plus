import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_confetti_plus/flutter_confetti_plus.dart';

void main() {
  group('ConfettiController', () {
    test('throws assertion error when `duration` is not positive', () {
      expect(
        () => ConfettiController(duration: const Duration(days: -20)),
        throwsAssertionError,
      );

      expect(
        () => ConfettiController(duration: const Duration(seconds: 0)),
        throwsAssertionError,
      );

      expect(
        () => ConfettiController(duration: const Duration(milliseconds: 0)),
        throwsAssertionError,
      );

      expect(
        () => ConfettiController(duration: const Duration(microseconds: 0)),
        throwsAssertionError,
      );
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

    testWidgets('launchParties inserts party confetti overlays', (
      tester,
    ) async {
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

    testWidgets('ConfettiPlus.launch inserts multiple cannon overlays', (
      tester,
    ) async {
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

      final future = ConfettiPlus.launch(
        context,
        cannons: [
          Cannon.left(
            emitter: ConfettiEmitter.burst(max: 10),
            timeToLive: const Duration(milliseconds: 10),
          ),
          Cannon.right(
            emitter: ConfettiEmitter.burst(max: 10),
            timeToLive: const Duration(milliseconds: 10),
          ),
        ],
        removeAfter: const Duration(milliseconds: 20),
      );

      await tester.pump();

      expect(find.byType(ConfettiWidget), findsNWidgets(2));

      await tester.pump(const Duration(milliseconds: 20));
      await future;
      await tester.pump();

      expect(find.byType(ConfettiWidget), findsNothing);
    });

    testWidgets('ConfettiPlus celebration types launch tuned overlays', (
      tester,
    ) async {
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

      final cases = [
        (
          launch:
              () => ConfettiPlus.success(
                context,
                removeAfter: const Duration(milliseconds: 20),
              ),
          count: 2,
          color: const Color(0xFF22C55E),
        ),
        (
          launch:
              () => ConfettiPlus.failure(
                context,
                removeAfter: const Duration(milliseconds: 20),
              ),
          count: 1,
          color: const Color(0xFFEF4444),
        ),
        (
          launch:
              () => ConfettiPlus.levelUp(
                context,
                removeAfter: const Duration(milliseconds: 20),
              ),
          count: 3,
          color: const Color(0xFFFACC15),
        ),
        (
          launch:
              () => ConfettiPlus.purchase(
                context,
                removeAfter: const Duration(milliseconds: 20),
              ),
          count: 3,
          color: const Color(0xFF16A34A),
        ),
      ];

      for (final celebration in cases) {
        final future = celebration.launch();

        await tester.pump();

        expect(find.byType(ConfettiWidget), findsNWidgets(celebration.count));
        final firstWidget = tester.widget<ConfettiWidget>(
          find.byType(ConfettiWidget).first,
        );
        expect(firstWidget.colors, contains(celebration.color));

        await tester.pump(const Duration(seconds: 1));
        await future;
        await tester.pump();

        expect(find.byType(ConfettiWidget), findsNothing);
      }
    });

    testWidgets('ConfettiPlus.sequence plays timeline steps', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

      final future = ConfettiPlus.sequence([
        ConfettiStep.burst(
          removeAfter: const Duration(milliseconds: 20),
          delayAfter: Duration.zero,
        ),
        ConfettiStep.fireworks(
          removeAfter: const Duration(milliseconds: 20),
          delayAfter: Duration.zero,
        ),
        ConfettiStep.rain(
          duration: const Duration(milliseconds: 10),
          removeAfter: const Duration(milliseconds: 20),
        ),
      ]);

      await tester.pump();

      expect(find.byType(ConfettiWidget), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await future;
      await tester.pump();

      expect(find.byType(ConfettiWidget), findsNothing);
    });

    testWidgets('ConfettiPlus.launchMode supports all motion modes', (
      tester,
    ) async {
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

      final cases = [
        (mode: ConfettiMode.fireworks, count: 2),
        (mode: ConfettiMode.fountain, count: 1),
        (mode: ConfettiMode.rain, count: 1),
        (mode: ConfettiMode.explosion, count: 1),
      ];

      for (final modeCase in cases) {
        final future = ConfettiPlus.launchMode(
          context,
          modeCase.mode,
          colors: const [Colors.cyan],
          removeAfter: const Duration(milliseconds: 20),
        );

        await tester.pump();

        expect(find.byType(ConfettiWidget), findsNWidgets(modeCase.count));
        final firstWidget = tester.widget<ConfettiWidget>(
          find.byType(ConfettiWidget).first,
        );
        expect(firstWidget.colors, contains(Colors.cyan));

        await tester.pump(const Duration(seconds: 1));
        await future;
        await tester.pump();

        expect(find.byType(ConfettiWidget), findsNothing);
      }
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

    test('Cannon presets map to bottom corner party blasts', () {
      final left = Cannon.left().toParty();
      final right = Cannon.right().toParty();

      expect(left.angle, ConfettiAngle.top + 45);
      expect(left.position.toAlignment(), Alignment.bottomLeft);
      expect(right.angle, ConfettiAngle.top - 45);
      expect(right.position.toAlignment(), Alignment.bottomRight);
    });

    test('ConfettiStep factories create expected timeline parties', () {
      expect(ConfettiStep.burst().parties, hasLength(1));
      expect(ConfettiStep.fireworks().parties, hasLength(2));
      expect(ConfettiStep.rain().parties, hasLength(1));
    });
  });
}
