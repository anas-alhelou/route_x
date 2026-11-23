import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/widgets/routex_main_button.dart';
import 'package:routex_mobile/core/widgets/routex_phone_field.dart';
import 'package:routex_mobile/core/widgets/routex_search_field.dart';
import 'package:routex_mobile/core/widgets/routex_text_field.dart';

/// Pumps [child] on a screen [width] wide (design size 412x917, 1:1 scale).
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double width = 412,
}) async {
  tester.view.physicalSize = Size(width, 917);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(412, 917),
      builder: (context, _) => MaterialApp(
        home: Scaffold(
          body: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// The box the field really paints: the container that carries its border.
Size _paintedBox(WidgetTester tester, Finder field) {
  final box = find.descendant(
    of: field,
    matching: find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).border != null,
    ),
  );
  return tester.getSize(box.first);
}

void main() {
  testWidgets('single-line text field paints a 56 tall box', (tester) async {
    await _pump(tester, const RouteXTextField(hintText: 'Email'));
    expect(_paintedBox(tester, find.byType(RouteXTextField)).height, 56);
  });

  testWidgets('password field paints a 56 tall box', (tester) async {
    await _pump(
      tester,
      const RouteXTextField(hintText: 'Password', obscureText: true),
    );
    expect(_paintedBox(tester, find.byType(RouteXTextField)).height, 56);
  });

  testWidgets('phone field paints a 56 tall box', (tester) async {
    await _pump(tester, const RouteXPhoneField());
    expect(_paintedBox(tester, find.byType(RouteXPhoneField)).height, 56);
  });

  testWidgets('multi-line field is taller than 56', (tester) async {
    await _pump(tester, const RouteXTextField(hintText: 'Notes', maxLines: 5));
    expect(tester.getSize(find.byType(TextField)).height, greaterThan(56));
  });

  testWidgets('text field is at most 360 wide on a wide screen', (
    tester,
  ) async {
    await _pump(tester, const RouteXTextField(hintText: 'Email'), width: 800);
    expect(_paintedBox(tester, find.byType(RouteXTextField)).width, 360);
  });

  testWidgets('main button is 360 x 56', (tester) async {
    await _pump(
      tester,
      RouteXMainButton(text: 'Login', onPressed: () {}),
      width: 800,
    );
    final size = tester.getSize(find.byType(ElevatedButton));
    expect(size.width, 360);
    expect(size.height, 56);
  });

  testWidgets('search field is 360 x 56', (tester) async {
    await _pump(
      tester,
      RouteXSearchField(hintText: 'Search', onChanged: (_) {}),
      width: 800,
    );
    final size = _paintedBox(tester, find.byType(RouteXSearchField));
    expect(size.width, 360);
    expect(size.height, 56);
  });
}
