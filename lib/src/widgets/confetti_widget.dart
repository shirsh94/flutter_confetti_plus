import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../controllers/confetti_controller.dart';
import '../enums/blast_directionality.dart';
import '../enums/confetti_controller_state.dart';
import '../party/confetti_position.dart';
import '../party/confetti_shapes.dart';
import '../particle_stats.dart';
import '../particles/confetti_particle_engine.dart';
import '../rendering/confetti_canvas_painter.dart';
import '../shared/confetti_timing.dart';

class ConfettiWidget extends StatefulWidget {
  const ConfettiWidget({
    Key? key,
    required this.confettiController,
    this.emissionFrequency = 0.02,
    this.numberOfParticles = 10,
    this.maxBlastForce = 20,
    this.minBlastForce = 5,
    this.blastDirectionality = ConfettiBlastDirection.directional,
    this.blastDirection = pi,
    this.spreadRadians = 0,
    this.gravity = 0.2,
    this.shouldLoop = false,
    this.displayTarget = false,
    this.colors,
    this.emojis,
    this.widgetSprites,
    this.strokeColor = Colors.black,
    this.strokeWidth = 0,
    this.minimumSize = const Size(20, 10),
    this.maximumSize = const Size(30, 15),
    this.particleDrag = 0.05,
    this.canvas,
    this.pauseEmissionOnLowFrameRate = true,
    this.createParticlePath,
    this.partySpawnPosition,
    this.partySizeOptions,
    this.partyShapeOptions,
    this.child,
  })  : assert(
          emissionFrequency >= 0 &&
              emissionFrequency <= 1 &&
              numberOfParticles > 0 &&
              maxBlastForce > 0 &&
              minBlastForce > 0 &&
              maxBlastForce > minBlastForce,
        ),
        assert(gravity >= 0 && gravity <= 1,
            '`gravity` needs to be between 0 and 1'),
        assert(strokeWidth >= 0, '`strokeWidth needs to be bigger than 0'),
        super(key: key);

  final ConfettiController confettiController;
  final double maxBlastForce;
  final double minBlastForce;
  final ConfettiBlastDirection blastDirectionality;
  final double blastDirection;
  final double spreadRadians;
  final Path Function(Size size)? createParticlePath;
  final double gravity;
  final double emissionFrequency;
  final int numberOfParticles;
  final bool shouldLoop;
  final bool displayTarget;
  final List<Color>? colors;
  final List<String>? emojis;
  final List<Widget>? widgetSprites;
  final double strokeWidth;
  final Color strokeColor;
  final Size minimumSize;
  final Size maximumSize;
  final double particleDrag;
  final Size? canvas;
  final bool pauseEmissionOnLowFrameRate;
  final ConfettiPosition? partySpawnPosition;
  final List<Size>? partySizeOptions;
  final List<ConfettiShape>? partyShapeOptions;
  final Widget? child;

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey _particleSystemKey = GlobalKey();
  final List<GlobalKey> _spriteKeys = <GlobalKey>[];

  late final AnimationController _animationController;
  late final ConfettiParticleEngine _particleEngine;

  Size _screenSize = Size.zero;
  List<ui.Image>? _spriteImages;
  bool _spriteCapturePending = false;
  late var _lastFrameTime = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    widget.confettiController.addListener(_handleControllerChange);
    _spriteKeys.addAll(
      List.generate(widget.widgetSprites?.length ?? 0, (_) => GlobalKey()),
    );
    _particleEngine = _createParticleEngine()
      ..addListener(_handleParticleEngineChange);
    _initAnimation();
  }

  ConfettiParticleEngine _createParticleEngine() {
    return ConfettiParticleEngine(
      emissionFrequency: widget.emissionFrequency,
      numberOfParticles: widget.numberOfParticles,
      maxBlastForce: widget.maxBlastForce,
      minBlastForce: widget.minBlastForce,
      gravity: widget.gravity,
      blastDirection: widget.blastDirection,
      blastDirectionality: widget.blastDirectionality,
      spreadRadians: widget.spreadRadians,
      colors: widget.colors,
      emojis: widget.emojis,
      spriteImages: _spriteImages,
      minimumSize: widget.minimumSize,
      maximumSize: widget.maximumSize,
      sizeOptions: widget.partySizeOptions,
      particleDrag: widget.particleDrag,
      spawnPosition: widget.partySpawnPosition,
      shapeOptions: widget.partyShapeOptions,
      createParticlePath: widget.createParticlePath,
    );
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.confettiController.duration,
    );
    Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(_tickParticles)
      ..addStatusListener(_handleAnimationStatus);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.confettiController.state == ConfettiControllerState.playing) {
        _startOrCapture();
      }
    });
  }

  void _handleControllerChange() {
    switch (widget.confettiController.state) {
      case ConfettiControllerState.playing:
        _startOrCapture();
        break;
      case ConfettiControllerState.stopped:
        _stopEmission();
        break;
      case ConfettiControllerState.stoppedAndCleared:
      case ConfettiControllerState.disposed:
        _stopEmission(clearAllParticles: true);
        break;
    }
  }

  void _tickParticles() {
    if (_particleEngine.status == ConfettiParticleEngineStatus.finished) {
      _animationController.stop();
      return;
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final deltaTime = (currentTime - _lastFrameTime) / 1000;
    _lastFrameTime = currentTime;

    _particleEngine.update(
      deltaTime > kLowLimit ? kLowLimit : deltaTime,
      pauseEmission:
          deltaTime > kLowLimit && widget.pauseEmissionOnLowFrameRate,
    );

    widget.confettiController.particleStatsCallback?.call(
      ParticleStats(
        numberOfParticles: _particleEngine.numberOfParticles,
        activeNumberOfParticles: _particleEngine.activeNumberOfParticles,
      ),
    );
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (!widget.shouldLoop) _stopEmission();
    _animationController.forward(from: 0);
  }

  void _handleParticleEngineChange() {
    if (_particleEngine.status == ConfettiParticleEngineStatus.finished) {
      _animationController.stop();
      widget.confettiController.stop();
    }
  }

  void _startAnimation() {
    if (!mounted) return;
    _syncCanvasGeometry();
    _animationController.forward(from: 0);
  }

  void _startOrCapture() {
    if (widget.widgetSprites == null || widget.widgetSprites!.isEmpty) {
      _startAnimation();
      _particleEngine.start();
      return;
    }

    if (_spriteImages != null) {
      _startAnimation();
      _particleEngine.start();
      return;
    }

    if (_spriteCapturePending) return;
    _spriteCapturePending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _captureSpriteImages();
      _spriteCapturePending = false;
      if (!mounted) return;
      _particleEngine
        ..spriteImages = _spriteImages
        ..start();
      _startAnimation();
    });
  }

  Future<void> _captureSpriteImages() async {
    final images = <ui.Image>[];
    for (final key in _spriteKeys) {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) continue;
      images.add(await boundary.toImage(pixelRatio: 2));
    }
    _spriteImages = images.isEmpty ? null : images;
  }

  void _stopEmission({bool clearAllParticles = false}) {
    if (_particleEngine.status == ConfettiParticleEngineStatus.stopped) return;
    _particleEngine.stop(clearAllParticles: clearAllParticles);
  }

  void _syncCanvasGeometry() {
    _screenSize = _screenSizeForContext();
    _particleEngine
      ..screenSize = _screenSize
      ..emitterPosition = _emitterPosition();
  }

  Offset _emitterPosition() {
    final renderBox =
        _particleSystemKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
  }

  Size _screenSizeForContext() {
    try {
      return widget.canvas ?? MediaQuery.of(context).size;
    } catch (e) {
      debugPrint('[flutter_confetti] Error getting screen size: $e');
      return widget.canvas ?? Size.zero;
    }
  }

  void _updateGeometryIfNeeded() {
    if (_screenSizeForContext() != _screenSize) {
      _syncCanvasGeometry();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateGeometryIfNeeded();
        });

        return RepaintBoundary(
          child: Stack(
            children: [
              CustomPaint(
                key: _particleSystemKey,
                willChange: true,
                foregroundPainter: ConfettiCanvasPainter(
                  _animationController,
                  strokeWidth: widget.strokeWidth,
                  strokeColor: widget.strokeColor,
                  particles: _particleEngine.particles,
                  paintEmitterTarget: widget.displayTarget,
                ),
                child: widget.child,
              ),
              if (widget.widgetSprites != null &&
                  widget.widgetSprites!.isNotEmpty)
                IgnorePointer(
                  child: Transform.translate(
                    offset: const Offset(-10000, -10000),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < widget.widgetSprites!.length; i++)
                          RepaintBoundary(
                            key: _spriteKeys[i],
                            child: widget.widgetSprites![i],
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    widget.confettiController.stop();
    _animationController.dispose();
    widget.confettiController.removeListener(_handleControllerChange);
    _particleEngine.removeListener(_handleParticleEngineChange);
    super.dispose();
  }
}
