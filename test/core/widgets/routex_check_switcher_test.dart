import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/widgets/routex_auth_frame.dart';
import 'package:routex_mobile/core/widgets/routex_check_switcher.dart';

Widget _host(bool on) => MaterialApp(
  home: Scaffold(
    body: RouteXCheckSwitcher(
      child: Icon(
        on ? Icons.check_circle : Icons.circle_outlined,
        key: ValueKey<bool>(on),
      ),
    ),
  ),
);

void main() {
  testWidgets('swapping the icon animates through a scale transition', (
    tester,
  ) async {
    await tester.pumpWidget(_host(false));
    await tester.pumpWidget(_host(true));
    await tester.pump(const Duration(milliseconds: 60));
    // Both icons are mid-transition: the old one leaving, the new one entering.
    expect(find.byType(Icon), findsNWidgets(2));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.circle_outlined), findsNothing);
  });

  testWidgets('with animations disabled the swap is instant', (tester) async {
    Widget host(bool on) => MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: _host(on),
    );
    await tester.pumpWidget(host(false));
    await tester.pumpWidget(host(true));
    await tester.pump();
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('auth frame caps content width and centres it', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RouteXAuthFrame(child: SizedBox.expand(key: Key('c'))),
        ),
      ),
    );
    final size = tester.getSize(find.byKey(const Key('c')));
    expect(size.width, RouteXAuthFrame.maxWidth);
    expect(
      tester.getCenter(find.byKey(const Key('c'))).dx,
      closeTo(500, 0.01),
    );
  });
}
