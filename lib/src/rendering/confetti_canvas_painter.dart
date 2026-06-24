import 'dart:math';

import 'package:flutter/material.dart';

import '../particles/confetti_particle_model.dart';

class ConfettiCanvasPainter extends CustomPainter {
  ConfettiCanvasPainter(
    Listenable? repaint, {
    required this.particles,
    bool paintEmitterTarget = true,
    Color emitterTargetColor = Colors.black,
    Color strokeColor = Colors.black,
    this.strokeWidth = 0,
  })  : _paintEmitterTarget = paintEmitterTarget,
        _emitterPaint = Paint()
          ..color = emitterTargetColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
        _particlePaint = Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill,
        _particleStrokePaint = Paint()
          ..color = strokeColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke,
        super(repaint: repaint);

  final List<ConfettiParticleModel> particles;
  final double strokeWidth;

  final Paint _emitterPaint;
  final bool _paintEmitterTarget;
  final Paint _particlePaint;
  final Paint _particleStrokePaint;

  @override
  void paint(Canvas canvas, Size size) {
    if (_paintEmitterTarget) _paintEmitter(canvas);
    _paintParticles(canvas);
  }

  void _paintEmitter(Canvas canvas) {
    const radius = 10.0;
    canvas.drawCircle(Offset.zero, radius, _emitterPaint);
    final path = Path()
      ..moveTo(0, -radius)
      ..lineTo(0, radius)
      ..moveTo(-radius, 0)
      ..lineTo(radius, 0);
    canvas.drawPath(path, _emitterPaint);
  }

  void _paintParticles(Canvas canvas) {
    for (final particle in particles) {
      if (!particle.active) continue;

      final transform = _particleTransform(particle);
      if (particle.emoji != null) {
        _paintEmojiParticle(canvas, particle, transform);
        continue;
      }

      if (particle.spriteImage != null) {
        _paintSpriteParticle(canvas, particle, transform);
        continue;
      }

      final finalPath = particle.path.transform(transform.storage);
      canvas.drawPath(finalPath, _particlePaint..color = particle.color);
      if (strokeWidth > 0) {
        canvas.drawPath(finalPath, _particleStrokePaint);
      }
    }
  }

  Matrix4 _particleTransform(ConfettiParticleModel particle) {
    final cosX = cos(particle.angleX);
    final sinX = sin(particle.angleX);
    final cosY = cos(particle.angleY);
    final sinY = sin(particle.angleY);
    final cosZ = particle.rotateZ ? cos(particle.angleZ) : 1.0;
    final sinZ = particle.rotateZ ? sin(particle.angleZ) : 0.0;

    return Matrix4(
      cosY * cosZ,
      cosX * sinZ + sinX * sinY * cosZ,
      sinX * sinZ - cosX * sinY * cosZ,
      0.0,
      -cosY * sinZ,
      cosX * cosZ - sinX * sinY * sinZ,
      sinX * cosZ + cosX * sinY * sinZ,
      0.0,
      sinY,
      -sinX * cosY,
      cosX * cosY,
      0.001,
      particle.location.dx,
      particle.location.dy,
      0.0,
      1.0,
    );
  }

  void _paintEmojiParticle(
    Canvas canvas,
    ConfettiParticleModel particle,
    Matrix4 transform,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: particle.emoji,
        style: TextStyle(
          color: particle.color,
          fontSize: max(particle.size.width, particle.size.height),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas
      ..save()
      ..transform(transform.storage);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  void _paintSpriteParticle(
    Canvas canvas,
    ConfettiParticleModel particle,
    Matrix4 transform,
  ) {
    final image = particle.spriteImage!;
    final src =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dst = Rect.fromCenter(
      center: Offset.zero,
      width: particle.size.width,
      height: particle.size.height,
    );

    canvas
      ..save()
      ..transform(transform.storage);
    canvas.drawImageRect(image, src, dst, Paint());
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
