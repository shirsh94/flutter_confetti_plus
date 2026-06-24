import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart' as vmath;
import 'dart:ui' as ui;

import '../shared/confetti_timing.dart';
import '../shared/random_tools.dart';

typedef GenerateParticleForce = vmath.Vector2 Function();

class ConfettiParticleModel {
  ConfettiParticleModel({
    required Color color,
    required String? emoji,
    required ui.Image? spriteImage,
    required Size size,
    required this.gravity,
    required double particleDrag,
    required Path Function(Size size)? createParticlePath,
    required this.generateParticleForce,
    Offset spawnOffset = Offset.zero,
  })  : _startUpForce = generateParticleForce(),
        _color = color,
        _emoji = emoji,
        _spriteImage = spriteImage,
        _size = size,
        _mass = RandomTools.between(1, 11),
        _particleDrag = particleDrag,
        _location = vmath.Vector2(spawnOffset.dx, spawnOffset.dy),
        _acceleration = vmath.Vector2.zero(),
        _velocity = vmath.Vector2(
          RandomTools.between(-3, 3),
          RandomTools.between(-3, 3),
        ),
        _pathShape = createParticlePath != null
            ? createParticlePath(size)
            : _createRectanglePath(size),
        _aVelocityX = RandomTools.between(-0.1, 0.1),
        _aVelocityY = RandomTools.between(-0.1, 0.1),
        _aVelocityZ = RandomTools.between(-0.1, 0.1),
        _rotateZ = RandomTools.coinFlip(),
        gravityVector = vmath.Vector2(0, lerpDouble(0.1, 5, gravity)!),
        _active = true;

  final double gravity;
  final GenerateParticleForce generateParticleForce;
  final vmath.Vector2 gravityVector;

  final vmath.Vector2 _startUpForce;
  final vmath.Vector2 _location;
  final vmath.Vector2 _velocity;
  final vmath.Vector2 _acceleration;

  final Color _color;
  final String? _emoji;
  final ui.Image? _spriteImage;
  final Size _size;
  final double _mass;
  final double _particleDrag;
  final Path _pathShape;
  final bool _rotateZ;

  bool _active;
  double _aX = 0;
  double _aY = 0;
  double _aZ = 0;
  double _aVelocityX;
  double _aVelocityY;
  double _aVelocityZ;
  double _timeAlive = 0;
  late final double _aAcceleration = 0.0001 / _mass;

  bool get active => _active;
  Color get color => _color;
  String? get emoji => _emoji;
  ui.Image? get spriteImage => _spriteImage;
  Size get size => _size;
  Path get path => _pathShape;
  double get angleX => _aX;
  double get angleY => _aY;
  double get angleZ => _aZ;
  bool get rotateZ => _rotateZ;

  Offset get location {
    if (_location.x.isNaN || _location.y.isNaN) return Offset.zero;
    return Offset(_location.x, _location.y);
  }

  void reactivate() {
    _timeAlive = 0;

    final force = generateParticleForce();
    _startUpForce.setValues(force.x, force.y);
    _location.setZero();
    _acceleration.setZero();
    _velocity.setValues(RandomTools.between(-3, 3), RandomTools.between(-3, 3));

    _aX = 0;
    _aY = 0;
    _aZ = 0;
    _aVelocityX = RandomTools.between(-0.1, 0.1);
    _aVelocityY = RandomTools.between(-0.1, 0.1);
    _aVelocityZ = RandomTools.between(-0.1, 0.1);
    gravityVector.setValues(0, lerpDouble(0.1, 5, gravity)!);

    _active = true;
  }

  void deactivate() {
    _active = false;
  }

  void update(double deltaTime) {
    final deltaTimeSpeed = deltaTime * desiredSpeed;
    _applyDrag(deltaTimeSpeed);

    if (_timeAlive < 5) {
      _applyForce(_startUpForce, deltaTimeSpeed);
    }
    if (_timeAlive < 25) {
      _applyForce(vmath.Vector2(0, -1), deltaTimeSpeed);
      _timeAlive += 1;
    }

    _applyForce(gravityVector, deltaTimeSpeed);
    _velocity.add(_acceleration * deltaTimeSpeed);
    _location.add(_velocity * deltaTimeSpeed);
    _acceleration.setZero();

    _aVelocityX += _aAcceleration;
    _aX += _aVelocityX * deltaTimeSpeed;
    _aVelocityY += _aAcceleration;
    _aY += _aVelocityY * deltaTimeSpeed;

    if (_rotateZ) {
      _aZ += _aVelocityZ * deltaTimeSpeed;
      _aVelocityZ += _aAcceleration;
    }
  }

  void _applyForce(vmath.Vector2 force, double deltaTimeSpeed) {
    final adjustedForce = force.clone()..divide(vmath.Vector2.all(_mass));
    _acceleration.add(adjustedForce * deltaTimeSpeed);
  }

  void _applyDrag(double deltaTimeSpeed) {
    final speed = sqrt(pow(_velocity.x, 2) + pow(_velocity.y, 2));
    final dragMagnitude = _particleDrag * speed * speed;
    final drag = _velocity.clone()
      ..multiply(vmath.Vector2.all(-1))
      ..normalize()
      ..multiply(vmath.Vector2.all(dragMagnitude));
    _applyForce(drag, deltaTimeSpeed);
  }

  static Path _createRectanglePath(Size size) {
    final pathShape = Path()
      ..moveTo(0, 0)
      ..lineTo(-size.width, 0)
      ..lineTo(-size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    if (kIsWeb) {
      pathShape
        ..lineTo(-size.width, 0)
        ..lineTo(-size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    }

    return pathShape;
  }
}
