import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../enums/blast_directionality.dart';
import '../enums/confetti_mode.dart';
import '../widgets/confetti_widget.dart';
import '../controllers/confetti_controller.dart';
import '../cannons/cannon.dart';
import '../party/confetti_angle.dart';
import '../party/confetti_emitter.dart';
import '../party/confetti_position.dart';
import '../party/party_launcher.dart';
import '../party/confetti_party.dart';
import '../timeline/confetti_step.dart';

class Confetti {
  const Confetti._();

  /// Shows a burst of confetti without manually creating a
  /// [ConfettiController] or placing a [ConfettiWidget] in the widget tree.
  static Future<void> show(
    BuildContext context, {
    Duration duration = const Duration(seconds: 1),
    Duration? removeAfter,
    Alignment alignment = Alignment.center,
    double emissionFrequency = 0.05,
    int numberOfParticles = 20,
    double maxBlastForce = 20,
    double minBlastForce = 5,
    ConfettiBlastDirection blastDirectionality =
        ConfettiBlastDirection.explosive,
    double blastDirection = pi,
    double gravity = 0.2,
    bool shouldLoop = false,
    bool displayTarget = false,
    List<Color>? colors,
    List<String>? emojis,
    List<Widget>? widgetSprites,
    Color strokeColor = Colors.black,
    double strokeWidth = 0,
    Size minimumSize = const Size(20, 10),
    Size maximumSize = const Size(30, 15),
    double particleDrag = 0.05,
    Size? canvas,
    bool pauseEmissionOnLowFrameRate = true,
    Path Function(Size size)? createParticlePath,
    bool rootOverlay = false,
  }) async {
    assert(!duration.isNegative && duration.inMicroseconds > 0);
    assert(
      removeAfter == null ||
          (!removeAfter.isNegative && removeAfter.inMicroseconds > 0),
    );
    assert(
      emojis == null ||
          (emojis.isNotEmpty && emojis.every((emoji) => emoji.isNotEmpty)),
    );

    final overlay = Overlay.of(context, rootOverlay: rootOverlay);
    final controller = ConfettiController(duration: duration);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: alignment,
              child: ConfettiWidget(
                confettiController: controller,
                emissionFrequency: emissionFrequency,
                numberOfParticles: numberOfParticles,
                maxBlastForce: maxBlastForce,
                minBlastForce: minBlastForce,
                blastDirectionality: blastDirectionality,
                blastDirection: blastDirection,
                gravity: gravity,
                shouldLoop: shouldLoop,
                displayTarget: displayTarget,
                colors: colors,
                emojis: emojis,
                widgetSprites: widgetSprites,
                strokeColor: strokeColor,
                strokeWidth: strokeWidth,
                minimumSize: minimumSize,
                maximumSize: maximumSize,
                particleDrag: particleDrag,
                canvas: canvas,
                pauseEmissionOnLowFrameRate: pauseEmissionOnLowFrameRate,
                createParticlePath: createParticlePath,
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    controller.play();

    await Future<void>.delayed(removeAfter ?? duration + duration);

    controller.dispose();
    entry.remove();
  }

  /// Shows a single Konfetti-style [Party] celebration.
  static Future<void> launchParty(
    BuildContext context,
    Party party, {
    bool rootOverlay = false,
    Duration? removeAfter,
  }) {
    return PartyLauncher.launch(
      context,
      party,
      rootOverlay: rootOverlay,
      removeAfter: removeAfter,
    );
  }

  /// Shows multiple [Party] celebrations at once.
  static Future<void> launchParties(
    BuildContext context,
    List<Party> parties, {
    bool rootOverlay = false,
    Duration? removeAfter,
  }) {
    return PartyLauncher.launchAll(
      context,
      parties,
      rootOverlay: rootOverlay,
      removeAfter: removeAfter,
    );
  }
}

class ConfettiPlus {
  const ConfettiPlus._();

  static const List<Color> _successColors = [
    Color(0xFF22C55E),
    Color(0xFF14B8A6),
    Color(0xFFFACC15),
    Color(0xFF38BDF8),
  ];

  static const List<Color> _failureColors = [
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFF64748B),
    Color(0xFFFCA5A5),
  ];

  static const List<Color> _levelUpColors = [
    Color(0xFFFACC15),
    Color(0xFF38BDF8),
    Color(0xFFA78BFA),
    Color(0xFFFB7185),
  ];

  static const List<Color> _purchaseColors = [
    Color(0xFF16A34A),
    Color(0xFFF59E0B),
    Color(0xFF0EA5E9),
    Color(0xFFFDE68A),
  ];

  /// Launches one or more cannon-style confetti blasts.
  ///
  /// When [cannons] is omitted, a single bottom-center cannon is used.
  static Future<void> launch(
    BuildContext context, {
    List<Cannon> cannons = const [Cannon()],
    bool rootOverlay = false,
    Duration? removeAfter,
  }) {
    if (cannons.isEmpty) return Future<void>.value();

    return PartyLauncher.launchAll(
      context,
      cannons.map((cannon) => cannon.toParty()).toList(growable: false),
      rootOverlay: rootOverlay,
      removeAfter: removeAfter,
    );
  }

  /// Launches a bright success celebration from both bottom corners.
  static Future<void> success(
    BuildContext context, {
    bool rootOverlay = false,
    Duration? removeAfter,
  }) {
    return launch(
      context,
      cannons: [
        Cannon.left(
          colors: _successColors,
          speed: 38,
          maxSpeed: 64,
          emitter: ConfettiEmitter.burst(max: 36),
        ),
        Cannon.right(
          colors: _successColors,
          speed: 38,
          maxSpeed: 64,
          emitter: ConfettiEmitter.burst(max: 36),
        ),
      ],
      rootOverlay: rootOverlay,
      removeAfter: removeAfter,
    );
  }

  /// Launches a compact failure burst with warmer warning colors.
  static Future<void> failure(
    BuildContext context, {
    bool rootOverlay = false,
    Duration? removeAfter,
  }) {
    return launch(
      context,
      cannons: [
        Cannon.center(
          colors: _failureColors,
          spread: ConfettiSpread.wide,
          speed: 22,
          maxSpeed: 38,
          emitter: ConfettiEmitter.burst(max: 24),
        ),
      ],
      rootOverlay: rootOverlay,
      removeAfter: removeAfter,
    );
  }

  /// Launches a bigger staged celebration for progression moments.
  static Future<void> levelUp(
    BuildContext context, {
    bool rootOverlay = false,
    Duration? removeAfter,
  }) {
    return launch(
      context,
      cannons: [
        Cannon.center(
          colors: _levelUpColors,
          spread: 55,
          speed: 48,
          maxSpeed: 78,
          emitter: ConfettiEmitter.burst(max: 44),
        ),
        Cannon.left(
          colors: _levelUpColors,
          spread: 40,
          speed: 42,
          maxSpeed: 72,
          delay: const Duration(milliseconds: 120),
          emitter: ConfettiEmitter.burst(max: 28),
        ),
        Cannon.right(
          colors: _levelUpColors,
          spread: 40,
          speed: 42,
          maxSpeed: 72,
          delay: const Duration(milliseconds: 120),
          emitter: ConfettiEmitter.burst(max: 28),
        ),
      ],
      rootOverlay: rootOverlay,
      removeAfter: removeAfter,
    );
  }

  /// Launches a polished purchase celebration with green and gold accents.
  static Future<void> purchase(
    BuildContext context, {
    bool rootOverlay = false,
    Duration? removeAfter,
  }) {
    return launch(
      context,
      cannons: [
        Cannon.left(
          colors: _purchaseColors,
          spread: 50,
          speed: 34,
          maxSpeed: 58,
          emitter: ConfettiEmitter.burst(max: 30),
        ),
        Cannon.center(
          colors: _purchaseColors,
          spread: 70,
          speed: 30,
          maxSpeed: 54,
          delay: const Duration(milliseconds: 80),
          emitter: ConfettiEmitter.burst(max: 26),
        ),
        Cannon.right(
          colors: _purchaseColors,
          spread: 50,
          speed: 34,
          maxSpeed: 58,
          emitter: ConfettiEmitter.burst(max: 30),
        ),
      ],
      rootOverlay: rootOverlay,
      removeAfter: removeAfter,
    );
  }

  /// Launches a high-level motion mode such as fireworks, fountain, rain, or
  /// explosion.
  static Future<void> launchMode(
    BuildContext context,
    ConfettiMode mode, {
    List<Color>? colors,
    bool rootOverlay = false,
    Duration? removeAfter,
  }) {
    return PartyLauncher.launchAll(
      context,
      _partiesForMode(mode, colors: colors),
      rootOverlay: rootOverlay,
      removeAfter: removeAfter,
    );
  }

  /// Plays a list of confetti steps in order.
  ///
  /// Pass [context] when launching from a nested navigator or dialog. When
  /// omitted, the mounted app overlay is resolved from the widget tree.
  static Future<void> sequence(
    List<ConfettiStep> steps, {
    BuildContext? context,
    bool rootOverlay = true,
  }) async {
    if (steps.isEmpty) return;

    final overlay =
        context == null
            ? _resolveAppOverlay()
            : Overlay.of(context, rootOverlay: rootOverlay);

    for (final step in steps) {
      await PartyLauncher.launchAllOnOverlay(
        overlay,
        step.parties,
        removeAfter: step.removeAfter,
      );

      if (step.delayAfter > Duration.zero) {
        await Future<void>.delayed(step.delayAfter);
      }
    }
  }

  static OverlayState _resolveAppOverlay() {
    final rootElement = WidgetsBinding.instance.rootElement;
    if (rootElement == null) {
      throw FlutterError(
        'ConfettiPlus.sequence could not find a mounted widget tree. '
        'Call it after runApp, or pass context: explicitly.',
      );
    }

    OverlayState? overlay;

    void visit(Element element) {
      if (overlay != null) return;

      if (element is StatefulElement && element.state is OverlayState) {
        overlay = element.state as OverlayState;
        return;
      }

      element.visitChildren(visit);
    }

    visit(rootElement);

    final resolved = overlay;
    if (resolved == null) {
      throw FlutterError(
        'ConfettiPlus.sequence could not find an Overlay. '
        'Wrap your app in MaterialApp, Navigator, or Overlay, or pass context: '
        'from a widget below an Overlay.',
      );
    }

    return resolved;
  }

  static List<Party> _partiesForMode(ConfettiMode mode, {List<Color>? colors}) {
    final resolvedColors = colors ?? kDefaultPartyColors;

    return switch (mode) {
      ConfettiMode.fireworks =>
        ConfettiStep.fireworks(colors: resolvedColors).parties,
      ConfettiMode.fountain => [
        Cannon.center(
          colors: resolvedColors,
          spread: 35,
          speed: 32,
          maxSpeed: 56,
          emitter: ConfettiEmitter.continuous(
            duration: const Duration(seconds: 2),
            perSecond: 45,
          ),
        ).toParty(),
      ],
      ConfettiMode.rain => [
        Party(
          speed: 0,
          maxSpeed: 15,
          damping: 0.9,
          angle: ConfettiAngle.bottom,
          spread: ConfettiSpread.round,
          colors: resolvedColors,
          emitter: ConfettiEmitter.continuous(
            duration: const Duration(seconds: 2),
            perSecond: 90,
          ),
          position: ConfettiPosition.between(
            const ConfettiPosition.relative(0.0, 0.0),
            const ConfettiPosition.relative(1.0, 0.0),
          ),
        ),
      ],
      ConfettiMode.explosion => [
        Party(
          speed: 0,
          maxSpeed: 34,
          damping: 0.9,
          spread: ConfettiSpread.round,
          colors: resolvedColors,
          emitter: ConfettiEmitter.burst(max: 90),
          position: const ConfettiPosition.relative(0.5, 0.3),
        ),
      ],
    };
  }
}
