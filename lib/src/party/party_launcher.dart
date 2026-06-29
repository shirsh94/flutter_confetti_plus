import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/confetti_controller.dart';
import '../widgets/confetti_widget.dart';
import 'confetti_party.dart';

/// Launches one or more [Party] configurations over the screen.
class PartyLauncher {
  const PartyLauncher._();

  /// Shows a single [Party] celebration.
  static Future<void> launch(
    BuildContext context,
    Party party, {
    bool rootOverlay = false,
    Duration? removeAfter,
  }) {
    return launchAll(
      context,
      [party],
      rootOverlay: rootOverlay,
      removeAfter: removeAfter,
    );
  }

  /// Shows multiple [Party] celebrations at once, like Konfetti's multi-party API.
  static Future<void> launchAll(
    BuildContext context,
    List<Party> parties, {
    bool rootOverlay = false,
    Duration? removeAfter,
  }) async {
    if (parties.isEmpty) return;

    final overlay = Overlay.of(context, rootOverlay: rootOverlay);
    return launchAllOnOverlay(overlay, parties, removeAfter: removeAfter);
  }

  /// Shows multiple [Party] celebrations on a resolved overlay.
  static Future<void> launchAllOnOverlay(
    OverlayState overlay,
    List<Party> parties, {
    Duration? removeAfter,
  }) async {
    if (parties.isEmpty) return;

    final entries = <OverlayEntry>[];
    final controllers = <ConfettiController>[];
    final delays = <Future<void>>[];

    for (final party in parties) {
      final config = PartyConfiguration.fromParty(party);
      final controller = ConfettiController(duration: config.duration);
      controllers.add(controller);

      Path Function(Size size)? shapePath;
      if (config.createParticlePath != null) {
        shapePath = config.createParticlePath;
      }

      late final OverlayEntry entry;
      entry = OverlayEntry(
        builder: (context) {
          return Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: config.alignment,
                child: ConfettiWidget(
                  confettiController: controller,
                  emissionFrequency: config.emissionFrequency,
                  numberOfParticles: config.numberOfParticles,
                  maxBlastForce: config.maxBlastForce,
                  minBlastForce: config.minBlastForce,
                  blastDirectionality: config.blastDirectionality,
                  blastDirection: config.blastDirection,
                  spreadRadians: config.spreadRadians,
                  gravity: config.gravity,
                  particleDrag: config.particleDrag,
                  colors: config.colors,
                  emojis: config.emojis,
                  minimumSize: config.minimumSize,
                  maximumSize: config.maximumSize,
                  createParticlePath: shapePath,
                  partySpawnPosition: config.position,
                  partySizeOptions: party.sizes,
                  partyShapeOptions: config.shapes,
                ),
              ),
            ),
          );
        },
      );

      entries.add(entry);
      overlay.insert(entry);

      if (config.delay > Duration.zero) {
        delays.add(
          Future<void>.delayed(config.delay, () {
            controller.play();
          }),
        );
      } else {
        controller.play();
      }
    }

    final longestParty = parties.reduce((current, next) {
      return current.playbackDuration > next.playbackDuration ? current : next;
    });
    final cleanupAfter =
        removeAfter ??
        longestParty.playbackDuration + longestParty.playbackDuration;

    await Future.wait(delays);
    await Future<void>.delayed(cleanupAfter);

    for (final controller in controllers) {
      controller.dispose();
    }
    for (final entry in entries) {
      entry.remove();
    }
  }
}
