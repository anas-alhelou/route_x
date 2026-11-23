import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/onboarding/presentation/widgets/slide_to_start.dart';

const _designSize = Size(412, 917);
const _knobKey = ValueKey('slideToStartKnob');

Future<void> _pumpSlideToStart(
  WidgetTester tester, {
  required VoidCallback onCompleted,
  bool disableAnimations = false,
}) async {
  await tester.binding.setSurfaceSize(_designSize);
  tester.view.physicalSize = _designSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: _designSize,
        disableAnimations: disableAnimations,
      ),
      child: MaterialApp(
        home: ScreenUtilInit(
          designSize: _designSize,
          builder: (context, child) => Scaffold(
            body: SlideToStart(label: 'Slide to get started', onCompleted: onCompleted),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Drags the knob horizontally by [dx] and releases, without relying on
/// [WidgetTester.pumpAndSettle] — the chevron shimmer repeats forever, so
/// settling never occurs.
Future<void> _dragKnobBy(WidgetTester tester, double dx) async {
  final gesture =
      await tester.startGesture(tester.getCenter(find.byKey(_knobKey)));
  await gesture.moveBy(Offset(dx, 0));
  await tester.pump();
  await gesture.up();
  await tester.pump();
}

void main() {
  testWidgets('springs back when released below the completion threshold',
      (tester) async {
    var completed = false;
    await _pumpSlideToStart(tester, onCompleted: () => completed = true);

    final startX = tester.getTopLeft(find.byKey(_knobKey)).dx;
    final trackWidth = tester.getSize(find.byType(SlideToStart)).width;
    const knobDiameter = 56.0;
    const knobPadding = 6.0;
    final maxDrag = trackWidth - knobDiameter - knobPadding * 2;

    await _dragKnobBy(tester, maxDrag * 0.5);
    // Let the spring-back simulation settle without touching the
    // ever-repeating shimmer controller via pumpAndSettle.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(completed, isFalse);
    expect(tester.getTopLeft(find.byKey(_knobKey)).dx, closeTo(startX, 1));
  });

  testWidgets('completes and calls onCompleted when released past the threshold',
      (tester) async {
    var completed = false;
    await _pumpSlideToStart(tester, onCompleted: () => completed = true);

    final trackWidth = tester.getSize(find.byType(SlideToStart)).width;
    const knobDiameter = 56.0;
    const knobPadding = 6.0;
    final maxDrag = trackWidth - knobDiameter - knobPadding * 2;

    await _dragKnobBy(tester, maxDrag * 0.85);

    // Snap to end (150ms) + completion delay (300ms).
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 350));

    expect(completed, isTrue);
  });

  testWidgets('a single tap completes the slider when animations are disabled',
      (tester) async {
    var completed = false;
    await _pumpSlideToStart(
      tester,
      onCompleted: () => completed = true,
      disableAnimations: true,
    );

    await tester.tap(find.byType(SlideToStart));
    await tester.pump();

    expect(completed, isTrue);
  });
}
