import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vmath;

import '../enums/blast_directionality.dart';
import '../party/confetti_position.dart';
import '../party/confetti_shapes.dart';
import '../shared/random_tools.dart';
import 'confetti_particle_model.dart';

/// {@template particle_system_status}
/// Represents the current status of the particle engine.
/// {@endtemplate}
enum ConfettiParticleEngineStatus {
  started,
  finished,
  stopped,
}

class ConfettiParticleEngine extends ChangeNotifier {
  ConfettiParticleEngine({
    required double emissionFrequency,
    required int numberOfParticles,
    required double maxBlastForce,
    required double minBlastForce,
    required double blastDirection,
    required ConfettiBlastDirection blastDirectionality,
    required double spreadRadians,
    required List<Color>? colors,
    required List<String>? emojis,
    required List<ui.Image>? spriteImages,
    required Size minimumSize,
    required Size maximumSize,
    required List<Size>? sizeOptions,
    required double particleDrag,
    required double gravity,
    required ConfettiPosition? spawnPosition,
    List<ConfettiShape>? shapeOptions,
    Path Function(Size size)? createParticlePath,
  })  : assert(maxBlastForce > 0 &&
            minBlastForce > 0 &&
            emissionFrequency >= 0 &&
            emissionFrequency <= 1 &&
            numberOfParticles > 0 &&
            minimumSize.width > 0 &&
            minimumSize.height > 0 &&
            maximumSize.width > 0 &&
            maximumSize.height > 0 &&
            minimumSize.width <= maximumSize.width &&
            minimumSize.height <= maximumSize.height &&
            particleDrag >= 0.0 &&
            particleDrag <= 1 &&
            (emojis == null ||
                (emojis.isNotEmpty &&
                    emojis.every((emoji) => emoji.isNotEmpty)))),
        assert(gravity >= 0 && gravity <= 1),
        _blastDirection = blastDirection,
        _blastDirectionality = blastDirectionality,
        _spreadRadians = spreadRadians,
        _gravity = gravity,
        _maxBlastForce = maxBlastForce,
        _minBlastForce = minBlastForce,
        _frequency = emissionFrequency,
        _numberOfParticles = numberOfParticles,
        _colors = colors,
        _emojis = emojis,
        _spriteImages = spriteImages,
        _minimumSize = minimumSize,
        _maximumSize = maximumSize,
        _sizeOptions = sizeOptions,
        _particleDrag = particleDrag,
        _spawnPosition = spawnPosition,
        _shapeOptions = shapeOptions,
        _createParticlePath = createParticlePath;

  final List<ConfettiParticleModel> _particles = [];
  final Random _random = Random();

  final double _frequency;
  final int _numberOfParticles;
  final double _maxBlastForce;
  final double _minBlastForce;
  final double _blastDirection;
  final ConfettiBlastDirection _blastDirectionality;
  final double _spreadRadians;
  final double _gravity;
  final List<Color>? _colors;
  final List<String>? _emojis;
  List<ui.Image>? _spriteImages;
  final Size _minimumSize;
  final Size _maximumSize;
  final List<Size>? _sizeOptions;
  final double _particleDrag;
  final ConfettiPosition? _spawnPosition;
  final List<ConfettiShape>? _shapeOptions;
  final Path Function(Size size)? _createParticlePath;

  ConfettiParticleEngineStatus? _status;
  Offset _emitterPosition = Offset.zero;
  Size _screenSize = Size.zero;
  late double _bottomBorder;
  late double _rightBorder;
  late double _leftBorder;

  List<ConfettiParticleModel> get particles => _particles;
  ConfettiParticleEngineStatus? get status => _status;

  int get numberOfParticles => _particles.length;

  int get activeNumberOfParticles {
    return _particles.fold(0, (count, particle) {
      return particle.active ? count + 1 : count;
    });
  }

  set emitterPosition(Offset position) {
    _emitterPosition = position;
  }

  set screenSize(Size size) {
    _screenSize = size;
    _bottomBorder = _screenSize.height * 1.1;
    _rightBorder = _screenSize.width * 1.1;
    _leftBorder = _screenSize.width - _rightBorder;
  }

  set spriteImages(List<ui.Image>? images) {
    _spriteImages = images;
  }

  void start() {
    _status = ConfettiParticleEngineStatus.started;
  }

  void stop({bool clearAllParticles = false}) {
    _status = ConfettiParticleEngineStatus.stopped;
    if (clearAllParticles) _particles.clear();
  }

  void finish() {
    _particles.clear();
    _status = ConfettiParticleEngineStatus.finished;
  }

  void update(double deltaTime, {bool pauseEmission = false}) {
    if (_status != ConfettiParticleEngineStatus.finished) {
      _updateParticles(deltaTime);
    }

    if (_status == ConfettiParticleEngineStatus.stopped && _particles.isEmpty) {
      finish();
      notifyListeners();
    }

    if (pauseEmission || _status != ConfettiParticleEngineStatus.started) {
      return;
    }

    if (_particles.isEmpty || _random.nextDouble() < _frequency) {
      _addParticles(number: _numberOfParticles);
    }
  }

  void _updateParticles(double deltaTime) {
    if (_status == ConfettiParticleEngineStatus.stopped) {
      _particles.removeWhere((particle) => _isOutsideScreen(particle.location));
      for (final particle in _particles) {
        particle.update(deltaTime);
      }
      return;
    }

    for (final particle in _particles) {
      if (_isOutsideScreen(particle.location)) {
        particle.deactivate();
        continue;
      }
      particle.update(deltaTime);
    }
  }

  bool _isOutsideScreen(Offset particleLocation) {
    final globalParticlePosition = particleLocation + _emitterPosition;
    return globalParticlePosition.dy >= _bottomBorder ||
        globalParticlePosition.dx >= _rightBorder ||
        globalParticlePosition.dx <= _leftBorder;
  }

  void _addParticles({int number = 1}) {
    var reusedParticles = 0;

    for (final particle in _particles) {
      if (!particle.active) {
        particle.reactivate();
        reusedParticles++;
        if (reusedParticles == number) return;
      }
    }

    for (var i = 0; i < number - reusedParticles; i++) {
      final size = _randomSize();
      _particles.add(
        ConfettiParticleModel(
          color: _randomColor(),
          emoji: _randomEmoji(),
          spriteImage: _randomSpriteImage(),
          size: size,
          gravity: _gravity,
          particleDrag: _particleDrag,
          createParticlePath: _resolveParticlePath(size),
          generateParticleForce: _generateParticleForce,
          spawnOffset: _randomSpawnOffset(),
        ),
      );
    }
  }

  vmath.Vector2 _generateParticleForce() {
    var blastDirection = _blastDirection;
    if (_blastDirectionality == ConfettiBlastDirection.explosive) {
      blastDirection = vmath.radians(_random.nextInt(359).toDouble());
    } else if (_spreadRadians > 0) {
      final halfSpread = _spreadRadians / 2;
      blastDirection += RandomTools.between(-halfSpread, halfSpread);
    }

    final blastRadius = RandomTools.between(_minBlastForce, _maxBlastForce);
    return vmath.Vector2(
      blastRadius * cos(blastDirection),
      blastRadius * sin(blastDirection),
    );
  }

  Color _randomColor() {
    if (_colors == null) return RandomTools.materialColor();
    if (_colors!.length == 1) return _colors![0];
    return _colors![_random.nextInt(_colors!.length)];
  }

  String? _randomEmoji() {
    if (_emojis == null) return null;
    if (_emojis!.length == 1) return _emojis![0];
    return _emojis![_random.nextInt(_emojis!.length)];
  }

  ui.Image? _randomSpriteImage() {
    if (_spriteImages == null || _spriteImages!.isEmpty) return null;
    if (_spriteImages!.length == 1) return _spriteImages!.first;
    return _spriteImages![_random.nextInt(_spriteImages!.length)];
  }

  Size _randomSize() {
    if (_sizeOptions != null && _sizeOptions!.isNotEmpty) {
      return _sizeOptions![_random.nextInt(_sizeOptions!.length)];
    }
    return Size(
      RandomTools.between(_minimumSize.width, _maximumSize.width),
      RandomTools.between(_minimumSize.height, _maximumSize.height),
    );
  }

  Offset _randomSpawnOffset() {
    if (_spawnPosition == null || _screenSize == Size.zero) {
      return Offset.zero;
    }

    if (_spawnPosition is ConfettiBetweenPosition) {
      final between = _spawnPosition! as ConfettiBetweenPosition;
      final point = between.resolveOffset(_screenSize, _random);
      final anchor = between.toAlignment();
      final anchorPoint = Offset(
        (anchor.x + 1) / 2 * _screenSize.width,
        (anchor.y + 1) / 2 * _screenSize.height,
      );
      return point - anchorPoint;
    }

    return Offset.zero;
  }

  Path Function(Size size)? _resolveParticlePath(Size size) {
    if (_createParticlePath != null) return _createParticlePath;
    if (_shapeOptions != null && _shapeOptions!.isNotEmpty) {
      final shape = _shapeOptions![_random.nextInt(_shapeOptions!.length)];
      return (Size _) => confettiShapePath(shape, size);
    }
    return null;
  }
}
