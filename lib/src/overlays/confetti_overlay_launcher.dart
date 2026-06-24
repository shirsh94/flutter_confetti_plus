import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../enums/blast_directionality.dart';
import '../widgets/confetti_widget.dart';
import '../controllers/confetti_controller.dart';
import '../party/party_launcher.dart';
import '../party/confetti_party.dart';

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
    ConfettiBlastDirection blastDirectionality = ConfettiBlastDirection.explosive,
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
    assert(removeAfter == null ||
        (!removeAfter.isNegative && removeAfter.inMicroseconds > 0));
    assert(emojis == null ||
        (emojis.isNotEmpty && emojis.every((emoji) => emoji.isNotEmpty)));

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
