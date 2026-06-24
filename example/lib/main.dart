import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_confetti_plus/flutter_confetti_plus.dart';

void main() => runApp(const ConfettiSample());

class ConfettiSample extends StatelessWidget {
  const ConfettiSample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Confetti Plus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF2DD4BF),
        useMaterial3: true,
      ),
      home: const ConfettiDemoPage(),
    );
  }
}

class ConfettiDemoPage extends StatefulWidget {
  const ConfettiDemoPage({super.key});

  @override
  State<ConfettiDemoPage> createState() => _ConfettiDemoPageState();
}

class _ConfettiDemoPageState extends State<ConfettiDemoPage> {
  late final ConfettiController _centerController;
  late final ConfettiController _rightController;
  late final ConfettiController _leftController;
  late final ConfettiController _topController;
  late final ConfettiController _bottomController;

  final TextEditingController _emojiController = TextEditingController();
  final TextEditingController _spriteController = TextEditingController();

  final List<String> _emojis = ['🎉', '🔥', '🚀', '💰'];
  final List<Widget> _widgetSprites = [
    const _SpriteBadge(
      label: 'A',
      icon: Icons.rocket_launch,
      color: Color(0xFF38BDF8),
    ),
    const _SpriteBadge(
      label: 'B',
      icon: Icons.local_fire_department,
      color: Color(0xFFFB7185),
    ),
    const _SpriteBadge(label: 'C', icon: Icons.star, color: Color(0xFFFACC15)),
  ];

  @override
  void initState() {
    super.initState();
    _centerController = ConfettiController(
      duration: const Duration(seconds: 10),
    );
    _rightController = ConfettiController(
      duration: const Duration(seconds: 10),
    );
    _leftController = ConfettiController(duration: const Duration(seconds: 10));
    _topController = ConfettiController(duration: const Duration(seconds: 10));
    _bottomController = ConfettiController(
      duration: const Duration(seconds: 10),
    );
  }

  @override
  void dispose() {
    _centerController.dispose();
    _rightController.dispose();
    _leftController.dispose();
    _topController.dispose();
    _bottomController.dispose();
    _emojiController.dispose();
    _spriteController.dispose();
    super.dispose();
  }

  void _addEmojis([String? value]) {
    final input = (value ?? _emojiController.text).trim();
    if (input.isEmpty) return;

    setState(() {
      _emojis.addAll(
        input.split(RegExp(r'\s+')).where((emoji) {
          return emoji.trim().isNotEmpty;
        }),
      );
    });
    _emojiController.clear();
  }

  void _removeEmoji(String emoji) {
    if (_emojis.length == 1) return;
    setState(() {
      _emojis.remove(emoji);
    });
  }

  void _addSprite([String? value]) {
    final input = (value ?? _spriteController.text).trim();
    if (input.isEmpty) return;

    setState(() {
      _widgetSprites.add(
        _SpriteBadge(
          label: input,
          icon: Icons.emoji_objects_outlined,
          color:
              Colors.primaries[_widgetSprites.length % Colors.primaries.length],
        ),
      );
    });
    _spriteController.clear();
  }

  void _removeSprite(Widget sprite) {
    if (_widgetSprites.length == 1) return;
    setState(() {
      _widgetSprites.remove(sprite);
    });
  }

  void _showEmojiConfetti() {
    Confetti.show(
      context,
      emojis: _emojis,
      numberOfParticles: 30,
      minimumSize: const Size(24, 24),
      maximumSize: const Size(46, 46),
      gravity: 0.25,
    );
  }

  void _showSpriteConfetti() {
    Confetti.show(
      context,
      widgetSprites: _widgetSprites,
      numberOfParticles: 24,
      minimumSize: const Size(28, 28),
      maximumSize: const Size(54, 54),
      gravity: 0.18,
    );
  }

  void _launchPartyPreset(List<Party> parties) {
    Confetti.launchParties(context, parties);
  }

  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1217),
        appBar: AppBar(
          backgroundColor: const Color(0xFF151922),
          title: const Text('Confetti Plus Examples'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.tune), text: 'Controllers'),
              Tab(icon: Icon(Icons.festival), text: 'Parties'),
              Tab(icon: Icon(Icons.widgets), text: 'Sprites'),
              Tab(icon: Icon(Icons.celebration), text: 'Emojis'),
            ],
          ),
        ),
        body: Stack(
          children: [
            _buildConfettiLayers(),
            SafeArea(
              top: false,
              child: TabBarView(
                children: [
                  _ControllerTab(
                    presets: [
                      _ConfettiPreset(
                        label: 'Blast stars',
                        icon: Icons.auto_awesome,
                        onPressed: _centerController.play,
                        details: const [
                          'blastDirectionality: explosive',
                          'shouldLoop: true',
                          'createParticlePath: drawStar',
                        ],
                      ),
                      _ConfettiPreset(
                        label: 'Left pump',
                        icon: Icons.keyboard_arrow_left,
                        onPressed: _rightController.play,
                        details: const [
                          'alignment: centerRight',
                          'blastDirection: pi',
                          'particleDrag: 0.05',
                        ],
                      ),
                      _ConfettiPreset(
                        label: 'Singles',
                        icon: Icons.looks_one,
                        onPressed: _leftController.play,
                        details: const [
                          'numberOfParticles: 1',
                          'emissionFrequency: 0.6',
                          'maximumSize: Size(50, 50)',
                        ],
                      ),
                      _ConfettiPreset(
                        label: 'Goliath',
                        icon: Icons.south,
                        onPressed: _topController.play,
                        details: const [
                          'alignment: topCenter',
                          'numberOfParticles: 50',
                          'gravity: 1',
                        ],
                      ),
                      _ConfettiPreset(
                        label: 'Cannon',
                        icon: Icons.north,
                        onPressed: _bottomController.play,
                        details: const [
                          'alignment: bottomCenter',
                          'blastDirection: -pi / 2',
                          'maxBlastForce: 100',
                        ],
                      ),
                    ],
                  ),
                  _PartyTab(onLaunch: _launchPartyPreset),
                  _SpriteTab(
                    sprites: _widgetSprites,
                    controller: _spriteController,
                    onAdd: _addSprite,
                    onRemove: _removeSprite,
                    onShow: _showSpriteConfetti,
                  ),
                  _EmojiTab(
                    emojis: _emojis,
                    controller: _emojiController,
                    onAdd: _addEmojis,
                    onRemove: _removeEmoji,
                    onShow: _showEmojiConfetti,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfettiLayers() {
    return IgnorePointer(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _centerController,
              blastDirectionality: ConfettiBlastDirection.explosive,
              shouldLoop: true,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
              createParticlePath: _drawStar,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _rightController,
              blastDirection: pi,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.05,
              colors: const [Colors.green, Colors.blue, Colors.pink],
              strokeWidth: 1,
              strokeColor: Colors.white,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _leftController,
              blastDirection: 0,
              emissionFrequency: 0.6,
              minimumSize: const Size(10, 10),
              maximumSize: const Size(50, 50),
              numberOfParticles: 1,
              gravity: 0.1,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _topController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 1,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConfettiWidget(
              confettiController: _bottomController,
              blastDirection: -pi / 2,
              emissionFrequency: 0.01,
              numberOfParticles: 20,
              maxBlastForce: 100,
              minBlastForce: 80,
              gravity: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControllerTab extends StatelessWidget {
  const _ControllerTab({required this.presets});

  final List<_ConfettiPreset> presets;

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      title: 'Controller patterns',
      subtitle: 'Long-running emitters driven by ConfettiController.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: presets.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: wide ? 2 : 1,
              mainAxisExtent: 220,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              return _PresetCard(preset: presets[index]);
            },
          );
        },
      ),
    );
  }
}

class _PartyTab extends StatelessWidget {
  const _PartyTab({required this.onLaunch});

  final ValueChanged<List<Party>> onLaunch;

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      title: 'Party presets',
      subtitle: 'One-shot overlay launches using Party configuration.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _PresetCard(
            preset: _ConfettiPreset(
              label: 'Festive',
              icon: Icons.celebration,
              onPressed: () => onLaunch(PartyPresets.festive()),
              details: const [
                'PartyPresets.festive()',
                'Balanced spread',
                'Good default celebration',
              ],
            ),
          ),
          _PresetCard(
            preset: _ConfettiPreset(
              label: 'Explode',
              icon: Icons.bubble_chart,
              onPressed: () => onLaunch(PartyPresets.explode()),
              details: const [
                'PartyPresets.explode()',
                'Center burst',
                'High impact feedback',
              ],
            ),
          ),
          _PresetCard(
            preset: _ConfettiPreset(
              label: 'Parade',
              icon: Icons.directions_run,
              onPressed: () => onLaunch(PartyPresets.parade()),
              details: const [
                'PartyPresets.parade()',
                'Side-to-side movement',
                'Multiple emitters',
              ],
            ),
          ),
          _PresetCard(
            preset: _ConfettiPreset(
              label: 'Rain',
              icon: Icons.water_drop,
              onPressed: () => onLaunch(PartyPresets.rain()),
              details: const [
                'PartyPresets.rain()',
                'Top emitter',
                'Soft falling motion',
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpriteTab extends StatelessWidget {
  const _SpriteTab({
    required this.sprites,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
    required this.onShow,
  });

  final List<Widget> sprites;
  final TextEditingController controller;
  final ValueChanged<String?> onAdd;
  final ValueChanged<Widget> onRemove;
  final VoidCallback onShow;

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      title: 'Widget sprites',
      subtitle: 'Any widget can become a confetti particle.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DemoSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PanelTitle(
                  icon: Icons.widgets,
                  title: 'Sprite set',
                  subtitle: 'Add labels, remove previews, then launch.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final sprite in sprites)
                      _SpritePreview(
                        sprite: sprite,
                        onRemove: () => onRemove(sprite),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onSubmitted: onAdd,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Add sprite label',
                          prefixIcon: Icon(Icons.add_box_outlined),
                          filled: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filledTonal(
                      onPressed: () => onAdd(null),
                      icon: const Icon(Icons.add),
                      tooltip: 'Add sprite',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onShow,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Launch widget sprites'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _CodeCard(
            lines: [
              'Confetti.show(context,',
              '  widgetSprites: sprites,',
              '  numberOfParticles: 24,',
              '  gravity: 0.18,',
              ');',
            ],
          ),
        ],
      ),
    );
  }
}

class _EmojiTab extends StatelessWidget {
  const _EmojiTab({
    required this.emojis,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
    required this.onShow,
  });

  final List<String> emojis;
  final TextEditingController controller;
  final ValueChanged<String?> onAdd;
  final ValueChanged<String> onRemove;
  final VoidCallback onShow;

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      title: 'Emoji overlay',
      subtitle: 'Fast bursts without placing a ConfettiWidget in the tree.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DemoSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PanelTitle(
                  icon: Icons.celebration,
                  title: 'Emoji mix',
                  subtitle: 'Enter one or more emoji separated by spaces.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final emoji in emojis)
                      InputChip(
                        label: Text(
                          emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        backgroundColor: Colors.white10,
                        deleteIconColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        onDeleted:
                            emojis.length == 1 ? null : () => onRemove(emoji),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onSubmitted: onAdd,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Add emoji',
                          prefixIcon: Icon(Icons.add_reaction_outlined),
                          filled: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filledTonal(
                      onPressed: () => onAdd(null),
                      icon: const Icon(Icons.add),
                      tooltip: 'Add emoji',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onShow,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Launch emoji confetti'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _CodeCard(
            lines: [
              'Confetti.show(context,',
              '  emojis: emojis,',
              '  numberOfParticles: 30,',
              '  gravity: 0.25,',
              ');',
            ],
          ),
        ],
      ),
    );
  }
}

class _TabScaffold extends StatelessWidget {
  const _TabScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _DemoHeader(title: title, subtitle: subtitle),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _DemoHeader extends StatelessWidget {
  const _DemoHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
      ],
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({required this.preset});

  final _ConfettiPreset preset;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 390),
      child: _DemoSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(preset.icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    preset.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: preset.onPressed,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ParameterList(lines: preset.details),
          ],
        ),
      ),
    );
  }
}

class _ParameterList extends StatelessWidget {
  const _ParameterList({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check, color: Color(0xFF34D399), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return _DemoSurface(
      child: SelectableText(
        lines.join('\n'),
        style: const TextStyle(
          color: Color(0xFFD1FAE5),
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}

class _SpritePreview extends StatelessWidget {
  const _SpritePreview({required this.sprite, required this.onRemove});

  final Widget sprite;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        sprite,
        Positioned(
          right: -6,
          top: -6,
          child: IconButton.filledTonal(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 16),
            tooltip: 'Remove sprite',
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}

class _SpriteBadge extends StatelessWidget {
  const _SpriteBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoSurface extends StatelessWidget {
  const _DemoSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1E27).withValues(alpha: 0.94),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfettiPreset {
  const _ConfettiPreset({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.details,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final List<String> details;
}
