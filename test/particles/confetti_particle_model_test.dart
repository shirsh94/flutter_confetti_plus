import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_confetti_plus/src/particles/confetti_particle_model.dart';
import 'package:vector_math/vector_math.dart' as vmath;

void main() {
  group('ConfettiParticleModel', () {
    ConfettiParticleModel createParticle({String? emoji}) {
      return ConfettiParticleModel(
        color: Colors.blue,
        emoji: emoji,
        spriteImage: null,
        size: const Size(12, 16),
        gravity: 0.2,
        particleDrag: 0.05,
        createParticlePath: null,
        generateParticleForce: () => vmath.Vector2(4, -8),
      );
    }

    test('starts active with configured visual payload', () {
      final particle = createParticle(emoji: '🚀');

      expect(particle.active, true);
      expect(particle.color, Colors.blue);
      expect(particle.emoji, '🚀');
      expect(particle.size, const Size(12, 16));
      expect(particle.path, isNotNull);
    });

    test('updates location and rotation over time', () {
      final particle = createParticle();
      final start = particle.location;

      particle.update(1 / 60);

      expect(particle.location, isNot(start));
      expect(particle.angleX, isNot(0));
      expect(particle.angleY, isNot(0));
    });

    test('can deactivate and reactivate', () {
      final particle = createParticle();

      particle
        ..update(1 / 60)
        ..deactivate();

      expect(particle.active, false);

      particle.reactivate();

      expect(particle.active, true);
      expect(particle.location, Offset.zero);
    });

    test('uses custom particle paths', () {
      final particle = ConfettiParticleModel(
        color: Colors.green,
        emoji: null,
        spriteImage: null,
        size: const Size(10, 10),
        gravity: 0.2,
        particleDrag: 0.05,
        createParticlePath: (size) {
          return Path()
            ..moveTo(0, 0)
            ..lineTo(size.width, 0)
            ..lineTo(0, size.height)
            ..close();
        },
        generateParticleForce: () => vmath.Vector2(1, 1),
      );

      expect(particle.path.getBounds().width, 10);
      expect(particle.path.getBounds().height, 10);
    });
  });
}
