import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/widgets/routex_pressable.dart';

Widget _app(Widget child, {bool reduceMotion = false}) => MaterialApp(
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: c!,
      ),
      home: Scaffold(body: Center(child: child)),
    );

double _scaleOf(WidgetTester tester) {
  final s = find.descendant(
    of: find.byType(RouteXTapScale),
    matching: find.byType(AnimatedScale),
  );
  return tester.widget<AnimatedScale>(s).scale;
}

void main() {
  group('RouteXTapScale', () {
    testWidgets('shrinks while held, restores on release, and still taps',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(RouteXTapScale(
        onTap: () => taps++,
        child: const SizedBox(width: 100, height: 50, child: Text('go')),
      )));
      expect(_scaleOf(tester), 1);

      final gesture = await tester.startGesture(tester.getCenter(find.text('go')));
      await tester.pump(const Duration(milliseconds: 50));
      expect(_scaleOf(tester), 0.97);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(_scaleOf(tester), 1);
      expect(taps, 1);
    });

    testWidgets('restores when the press is cancelled by a drag',
        (tester) async {
      await tester.pumpWidget(_app(RouteXTapScale(
        onTap: () {},
        child: const SizedBox(width: 100, height: 50, child: Text('go')),
      )));
      final gesture = await tester.startGesture(tester.getCenter(find.text('go')));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveBy(const Offset(0, 300));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_scaleOf(tester), 1);
    });

    testWidgets('does not scale when there is no onTap', (tester) async {
      await tester.pumpWidget(_app(const RouteXTapScale(
        onTap: null,
        child: SizedBox(width: 100, height: 50, child: Text('go')),
      )));
      expect(find.descendant(
        of: find.byType(RouteXTapScale),
        matching: find.byType(AnimatedScale),
      ), findsNothing);
    });

    testWidgets('does not scale with reduced motion but still taps',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(
        RouteXTapScale(
          onTap: () => taps++,
          child: const SizedBox(width: 100, height: 50, child: Text('go')),
        ),
        reduceMotion: true,
      ));
      expect(find.descendant(
        of: find.byType(RouteXTapScale),
        matching: find.byType(AnimatedScale),
      ), findsNothing);
      await tester.tap(find.text('go'));
      expect(taps, 1);
    });
  });

  group('RouteXPressable', () {
    testWidgets('has no scale with reduced motion', (tester) async {
      await tester.pumpWidget(_app(
        RouteXPressable(
          onTap: () {},
          child: const SizedBox(width: 100, height: 50, child: Text('go')),
        ),
        reduceMotion: true,
      ));
      expect(find.descendant(
        of: find.byType(RouteXPressable),
        matching: find.byType(AnimatedScale),
      ), findsNothing);
    });

    testWidgets('scales when motion is allowed', (tester) async {
      await tester.pumpWidget(_app(
        RouteXPressable(
          onTap: () {},
          child: const SizedBox(width: 100, height: 50, child: Text('go')),
        ),
      ));
      expect(find.descendant(
        of: find.byType(RouteXPressable),
        matching: find.byType(AnimatedScale),
      ), findsOneWidget);
    });
  });
}
