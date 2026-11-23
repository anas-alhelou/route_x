import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/motion.dart';
import 'package:routex_mobile/core/widgets/routex_pop_in.dart';

Widget _app({bool reduceMotion = false}) => MaterialApp(
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: c!,
      ),
      home: const Scaffold(
        body: Center(
          child: RouteXPopIn(child: SizedBox(width: 40, height: 40, key: Key('badge'))),
        ),
      ),
    );

Transform _transform(WidgetTester tester) => tester.widget<Transform>(
      find.descendant(of: find.byType(RouteXPopIn), matching: find.byType(Transform)),
    );

void main() {
  testWidgets('starts faded and at 90%, then settles at full size', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump();
    final opacity = tester.widget<Opacity>(
      find.descendant(of: find.byType(RouteXPopIn), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, lessThan(0.2));
    expect(_transform(tester).transform.storage[0],
        closeTo(Motion.popInStartScale, 0.02));

    await tester.pumpAndSettle();
    expect(_transform(tester).transform.storage[0], closeTo(1, 0.001));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('with reduced motion the child is just there', (tester) async {
    await tester.pumpWidget(_app(reduceMotion: true));
    expect(find.descendant(of: find.byType(RouteXPopIn), matching: find.byType(Opacity)), findsNothing);
    expect(find.byKey(const Key('badge')), findsOneWidget);
  });
}
