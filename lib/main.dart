// In-Class Activity 06 - Drawing with Flutter
// Student: Myles Miller
// Date: September 29, 2026

import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const SmileyApp());

enum FaceKind { classic, sleepy, surprised }

@immutable
class FaceConfig {
  const FaceConfig({
    this.mood = .82,
    this.kind = FaceKind.classic,
    this.colorVariant = 0,
    this.eyeScale = 1,
    this.eyeGap = .35,
    this.blush = true,
    this.hat = false,
    this.glasses = false,
    this.mustache = false,
  });

  final double mood;
  final FaceKind kind;
  final int colorVariant;
  final double eyeScale, eyeGap;
  final bool blush, hat, glasses, mustache;

  FaceConfig copyWith({
    double? mood,
    FaceKind? kind,
    int? colorVariant,
    double? eyeScale,
    double? eyeGap,
    bool? blush,
    bool? hat,
    bool? glasses,
    bool? mustache,
  }) => FaceConfig(
    mood: mood ?? this.mood,
    kind: kind ?? this.kind,
    colorVariant: colorVariant ?? this.colorVariant,
    eyeScale: eyeScale ?? this.eyeScale,
    eyeGap: eyeGap ?? this.eyeGap,
    blush: blush ?? this.blush,
    hat: hat ?? this.hat,
    glasses: glasses ?? this.glasses,
    mustache: mustache ?? this.mustache,
  );

  Color get faceColor {
    const cool = [Color(0xffa6c8ff), Color(0xff9ddde4), Color(0xffb8b3f2)];
    const calm = [Color(0xffffdc77), Color(0xfff4d485), Color(0xfffde68a)];
    const warm = [Color(0xffffb665), Color(0xffffa878), Color(0xffffc363)];
    return (mood < .35
        ? cool
        : mood <= .70
        ? calm
        : warm)[colorVariant % 3];
  }

  String get moodName => mood < .35
      ? 'Low'
      : mood <= .70
      ? 'Calm'
      : 'Happy';

  @override
  bool operator ==(Object other) =>
      other is FaceConfig &&
      other.mood == mood &&
      other.kind == kind &&
      other.colorVariant == colorVariant &&
      other.eyeScale == eyeScale &&
      other.eyeGap == eyeGap &&
      other.blush == blush &&
      other.hat == hat &&
      other.glasses == glasses &&
      other.mustache == mustache;

  @override
  int get hashCode => Object.hash(
    mood,
    kind,
    colorVariant,
    eyeScale,
    eyeGap,
    blush,
    hat,
    glasses,
    mustache,
  );
}

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Smiley Painter Lab',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff244e70)),
      scaffoldBackgroundColor: const Color(0xfff5f8fa),
    ),
    home: const DrawingPlayground(),
  );
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});
  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  FaceConfig _config = const FaceConfig();
  final List<FaceConfig> _history = [];
  FaceConfig? _dragStart;
  final math.Random _random = math.Random();

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  void _commit(FaceConfig next, {String? message}) {
    if (next == _config) return;
    setState(() {
      _history.add(_config);
      _config = next;
    });
    if (message != null) _message(message);
  }

  void _beginDrag() => _dragStart = _config;
  void _updateDrag(FaceConfig next) => setState(() => _config = next);
  void _endDrag() {
    final start = _dragStart;
    _dragStart = null;
    if (start != null && start != _config) setState(() => _history.add(start));
  }

  void _choose(FaceKind kind) => _commit(
    _config.copyWith(kind: kind),
    message:
        '${kind.name[0].toUpperCase()}${kind.name.substring(1)} face selected.',
  );

  void _cycleFace() => _choose(
    FaceKind.values[(_config.kind.index + 1) % FaceKind.values.length],
  );

  void _randomize() {
    var mood = _random.nextDouble();
    var color = _random.nextInt(3);
    if ((mood - _config.mood).abs() < .08 && color == _config.colorVariant) {
      mood = 1 - mood;
      color = (color + 1) % 3;
    }
    final next = _config.copyWith(mood: mood, colorVariant: color);
    _commit(
      next,
      message: 'New ${next.moodName.toLowerCase()} mood and face color.',
    );
  }

  void _undo() {
    if (_history.isEmpty) {
      _message('Nothing to undo yet. Change the face first.');
      return;
    }
    setState(() => _config = _history.removeLast());
    _message('Previous face restored.');
  }

  String get _kindName =>
      '${_config.kind.name[0].toUpperCase()}'
      '${_config.kind.name.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final faceSize = math.min(
      340.0,
      math.min(screen.width - 48, screen.height * .49),
    );
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smiley Painter Lab'),
        actions: [
          IconButton(
            tooltip: 'Undo',
            onPressed: _undo,
            icon: const Icon(Icons.undo_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Draw your mood',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap the face to switch styles. Hold it to surprise yourself.',
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      child: Column(
                        children: [
                          Semantics(
                            label:
                                '${_config.kind.name} face, ${_config.moodName.toLowerCase()} mood. Tap to change face, long press to randomize.',
                            child: GestureDetector(
                              key: const Key('faceGesture'),
                              behavior: HitTestBehavior.opaque,
                              onTap: _cycleFace,
                              onLongPress: _randomize,
                              child: CustomPaint(
                                key: const Key('facePaint'),
                                size: Size.square(faceSize),
                                painter: SmileyPainter(config: _config),
                              ),
                            ),
                          ),
                          Text(
                            '$_kindName • ${_config.moodName}',
                            key: const Key('faceLabel'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Undo steps: ${_history.length}',
                            key: const Key('historyLabel'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Choose a face',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: FaceKind.values
                        .map(
                          (kind) => ChoiceChip(
                            label: Text(
                              '${kind.name[0].toUpperCase()}${kind.name.substring(1)}',
                            ),
                            selected: _config.kind == kind,
                            onSelected: (_) => _choose(kind),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  _controlCard(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _controlCard(BuildContext context) => Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fine tune',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Mood • ${_config.moodName} (${_config.mood.toStringAsFixed(2)})',
            key: const Key('moodLabel'),
          ),
          Slider(
            key: const Key('moodSlider'),
            value: _config.mood,
            onChangeStart: (_) => _beginDrag(),
            onChanged: (v) => _updateDrag(_config.copyWith(mood: v)),
            onChangeEnd: (_) => _endDrag(),
          ),
          Text('Eye size • ${_config.eyeScale.toStringAsFixed(2)}×'),
          Slider(
            key: const Key('eyeSizeSlider'),
            value: _config.eyeScale,
            min: .65,
            max: 1.55,
            onChangeStart: (_) => _beginDrag(),
            onChanged: (v) => _updateDrag(_config.copyWith(eyeScale: v)),
            onChangeEnd: (_) => _endDrag(),
          ),
          Text('Eye spacing • ${_config.eyeGap.toStringAsFixed(2)} radius'),
          Slider(
            key: const Key('eyeGapSlider'),
            value: _config.eyeGap,
            min: .24,
            max: .48,
            onChangeStart: (_) => _beginDrag(),
            onChanged: (v) => _updateDrag(_config.copyWith(eyeGap: v)),
            onChangeEnd: (_) => _endDrag(),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Blush'),
            subtitle: const Text('Soft ovals on each cheek'),
            value: _config.blush,
            onChanged: (v) => _commit(_config.copyWith(blush: v)),
          ),
          const Divider(),
          Text(
            'Accessories',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Hat'),
                selected: _config.hat,
                onSelected: (v) => _commit(
                  _config.copyWith(hat: v),
                  message: v ? 'Hat added.' : 'Hat removed.',
                ),
              ),
              FilterChip(
                label: const Text('Glasses'),
                selected: _config.glasses,
                onSelected: (v) => _commit(
                  _config.copyWith(glasses: v),
                  message: v ? 'Glasses added.' : 'Glasses removed.',
                ),
              ),
              FilterChip(
                label: const Text('Mustache'),
                selected: _config.mustache,
                onSelected: (v) => _commit(
                  _config.copyWith(mustache: v),
                  message: v ? 'Mustache added.' : 'Mustache removed.',
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class SmileyPainter extends CustomPainter {
  const SmileyPainter({required this.config});
  final FaceConfig config;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * .40;
    final dark = Paint()..color = const Color(0xff263746);

    // Later canvas commands appear above earlier ones.
    canvas.drawCircle(
      center.translate(0, radius * .055),
      radius,
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * .08),
    );
    canvas.drawCircle(center, radius, Paint()..color = config.faceColor);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = dark.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * .035,
    );

    final eyeY = center.dy - radius * .22;
    final eyeDx = radius * config.eyeGap;
    final eyeRadius = radius * .085 * config.eyeScale;
    for (final sign in [-1.0, 1.0]) {
      final eye = Offset(center.dx + sign * eyeDx, eyeY);
      if (config.kind == FaceKind.sleepy) {
        canvas.drawArc(
          Rect.fromCenter(
            center: eye,
            width: eyeRadius * 2.8,
            height: eyeRadius * 1.6,
          ),
          .13 * math.pi,
          .74 * math.pi,
          false,
          Paint()
            ..color = dark.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = radius * .04
            ..strokeCap = StrokeCap.round,
        );
      } else {
        canvas.drawCircle(
          eye,
          eyeRadius * (config.kind == FaceKind.surprised ? 1.2 : 1),
          dark,
        );
        canvas.drawCircle(
          eye.translate(-eyeRadius * .25, -eyeRadius * .25),
          eyeRadius * .25,
          Paint()..color = Colors.white,
        );
      }
    }

    if (config.blush) {
      for (final sign in [-1.0, 1.0]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: center.translate(sign * radius * .60, radius * .17),
            width: radius * .30,
            height: radius * .16,
          ),
          Paint()..color = const Color(0x88e97788),
        );
      }
    }

    final mouthPaint = Paint()
      ..color = dark.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * .05
      ..strokeCap = StrokeCap.round;
    if (config.kind == FaceKind.surprised) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center.translate(0, radius * .38),
          width: radius * .38,
          height: radius * (.50 + config.mood * .25),
        ),
        dark,
      );
    } else {
      // Center, width and height are all fractions of the available canvas.
      final mouthRect = Rect.fromCenter(
        center: center.translate(
          0,
          radius * (config.kind == FaceKind.sleepy ? .20 : .23),
        ),
        width: radius * (config.kind == FaceKind.sleepy ? .82 : 1.03),
        height:
            radius *
            (config.kind == FaceKind.sleepy ? .22 : .32 + config.mood * .58),
      );
      if (config.mood < .35 && config.kind == FaceKind.classic) {
        canvas.drawArc(
          mouthRect.translate(0, radius * .25),
          1.15 * math.pi,
          .70 * math.pi,
          false,
          mouthPaint,
        );
      } else {
        canvas.drawArc(
          mouthRect,
          .15 * math.pi,
          .70 * math.pi,
          false,
          mouthPaint,
        );
      }
    }

    if (config.mustache) {
      final path = Path()
        ..moveTo(center.dx, center.dy + radius * .30)
        ..cubicTo(
          center.dx - radius * .10,
          center.dy + radius * .15,
          center.dx - radius * .20,
          center.dy + radius * .36,
          center.dx - radius * .40,
          center.dy + radius * .30,
        )
        ..cubicTo(
          center.dx - radius * .24,
          center.dy + radius * .48,
          center.dx - radius * .10,
          center.dy + radius * .40,
          center.dx,
          center.dy + radius * .30,
        )
        ..cubicTo(
          center.dx + radius * .10,
          center.dy + radius * .40,
          center.dx + radius * .24,
          center.dy + radius * .48,
          center.dx + radius * .40,
          center.dy + radius * .30,
        )
        ..cubicTo(
          center.dx + radius * .20,
          center.dy + radius * .36,
          center.dx + radius * .10,
          center.dy + radius * .15,
          center.dx,
          center.dy + radius * .30,
        );
      canvas.drawPath(path, dark);
    }
    if (config.glasses) {
      final frame = Paint()
        ..color = const Color(0xff344c70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * .035;
      for (final sign in [-1.0, 1.0]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(center.dx + sign * eyeDx, eyeY),
              width: radius * .43,
              height: radius * .34,
            ),
            Radius.circular(radius * .07),
          ),
          frame,
        );
      }
      canvas.drawLine(
        Offset(center.dx - eyeDx + radius * .22, eyeY),
        Offset(center.dx + eyeDx - radius * .22, eyeY),
        frame,
      );
    }
    if (config.hat) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center.translate(0, -radius * .91),
            width: radius * 1.05,
            height: radius * .45,
          ),
          Radius.circular(radius * .10),
        ),
        Paint()..color = const Color(0xff33465d),
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: center.translate(0, -radius * .74),
          width: radius * 1.35,
          height: radius * .10,
        ),
        Paint()..color = const Color(0xff263746),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SmileyPainter old) =>
      old.config.mood != config.mood ||
      old.config.kind != config.kind ||
      old.config.colorVariant != config.colorVariant ||
      old.config.eyeScale != config.eyeScale ||
      old.config.eyeGap != config.eyeGap ||
      old.config.blush != config.blush ||
      old.config.hat != config.hat ||
      old.config.glasses != config.glasses ||
      old.config.mustache != config.mustache;
}
