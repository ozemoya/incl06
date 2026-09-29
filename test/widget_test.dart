import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incl06/main.dart';

void main() {
  test('painter redraw decision compares every visual input', () {
    const base = FaceConfig();
    const original = SmileyPainter(config: base);
    expect(
      const SmileyPainter(config: FaceConfig()).shouldRepaint(original),
      false,
    );
    final changed = <FaceConfig>[
      base.copyWith(mood: .20),
      base.copyWith(kind: FaceKind.sleepy),
      base.copyWith(colorVariant: 1),
      base.copyWith(eyeScale: 1.3),
      base.copyWith(eyeGap: .42),
      base.copyWith(blush: false),
      base.copyWith(hat: true),
      base.copyWith(glasses: true),
      base.copyWith(mustache: true),
    ];
    for (final config in changed) {
      expect(SmileyPainter(config: config).shouldRepaint(original), true);
    }
    expect(base.faceColor, isNot(base.copyWith(mood: .1).faceColor));
  });

  testWidgets('face changes, mood drag, accessories and undo work together', (
    t,
  ) async {
    await t.pumpWidget(const SmileyApp());
    expect(find.text('Classic • Happy'), findsOneWidget);
    await t.tap(find.byKey(const Key('faceGesture')));
    await t.pumpAndSettle();
    expect(find.text('Sleepy • Happy'), findsOneWidget);
    await t.ensureVisible(find.text('Surprised'));
    await t.tap(find.text('Surprised'));
    await t.pumpAndSettle();
    expect(find.text('Surprised • Happy'), findsOneWidget);
    final slider = t.widget<Slider>(find.byKey(const Key('moodSlider')));
    slider.onChangeStart!(slider.value);
    slider.onChanged!(.2);
    await t.pump();
    slider.onChangeEnd!(.2);
    await t.pumpAndSettle();
    expect(find.text('Surprised • Low'), findsOneWidget);
    await t.ensureVisible(find.text('Hat'));
    await t.tap(find.text('Hat'));
    await t.pumpAndSettle();
    expect(
      t.widget<FilterChip>(find.widgetWithText(FilterChip, 'Hat')).selected,
      true,
    );
    await t.tap(find.byTooltip('Undo'));
    await t.pumpAndSettle();
    expect(
      t.widget<FilterChip>(find.widgetWithText(FilterChip, 'Hat')).selected,
      false,
    );
    await t.tap(find.byTooltip('Undo'));
    await t.pumpAndSettle();
    expect(find.text('Surprised • Happy'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('compact portrait and landscape layouts do not overflow', (
    t,
  ) async {
    for (final size in [const Size(360, 640), const Size(640, 360)]) {
      t.view.physicalSize = size;
      t.view.devicePixelRatio = 1;
      await t.pumpWidget(const SmileyApp());
      await t.pumpAndSettle();
      expect(find.byKey(const Key('facePaint')), findsOneWidget);
      expect(t.takeException(), isNull);
    }
    t.view.resetPhysicalSize();
    t.view.resetDevicePixelRatio();
  });
}
