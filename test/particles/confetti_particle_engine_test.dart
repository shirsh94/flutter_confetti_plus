import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_confetti_plus/src/enums/blast_directionality.dart';
import 'package:flutter_confetti_plus/src/particles/confetti_particle_engine.dart';

void main() {
  group('ConfettiParticleEngine', () {
    ConfettiParticleEngine createEngine({
      List<String>? emojis,
      List<ui.Image>? spriteImages,
      Size screenSize = const Size(400, 400),
    }) {
      final engine = ConfettiParticleEngine(
        emissionFrequency: 1,
        numberOfParticles: 3,
        maxBlastForce: 10,
        minBlastForce: 2,
        blastDirection: pi,
        blastDirectionality: ConfettiBlastDirection.directional,
        spreadRadians: 0,
        colors: const [Colors.red],
        emojis: emojis,
        spriteImages: spriteImages,
        minimumSize: const Size(10, 10),
        maximumSize: const Size(20, 20),
        sizeOptions: null,
        particleDrag: 0.05,
        gravity: 0.2,
        spawnPosition: null,
        shapeOptions: null,
      );

      engine
        ..screenSize = screenSize
        ..emitterPosition = Offset.zero;
      return engine;
    }

    test('starts and emits particles on update', () {
      final engine = createEngine();

      engine.start();
      engine.update(1 / 60);

      expect(engine.status, ConfettiParticleEngineStatus.started);
      expect(engine.numberOfParticles, 3);
      expect(engine.activeNumberOfParticles, 3);
    });

    test('assigns emoji payloads when emojis are provided', () {
      final engine = createEngine(emojis: const ['🎉']);

      engine.start();
      engine.update(1 / 60);

      expect(engine.particles, isNotEmpty);
      expect(
          engine.particles.every((particle) => particle.emoji == '🎉'), true);
    });

    test('clears particles when stopped with clearAllParticles', () {
      final engine = createEngine();

      engine.start();
      engine.update(1 / 60);
      engine.stop(clearAllParticles: true);

      expect(engine.status, ConfettiParticleEngineStatus.stopped);
      expect(engine.numberOfParticles, 0);
    });

    test('finishes after stopped particles leave the screen', () {
      final engine = createEngine(screenSize: const Size(1, 1));
      var notified = false;
      engine.addListener(() => notified = true);

      engine.start();
      engine.update(1 / 60);
      engine.stop();

      for (var i = 0; i < 20; i++) {
        engine.update(1);
      }

      expect(engine.status, ConfettiParticleEngineStatus.finished);
      expect(notified, true);
    });

    test('rejects empty emoji lists and empty emoji values', () {
      expect(() => createEngine(emojis: const []), throwsAssertionError);
      expect(() => createEngine(emojis: const ['']), throwsAssertionError);
    });
  });
}
