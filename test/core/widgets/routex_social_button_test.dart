import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/widgets/routex_social_button.dart';

Future<void> _pump(WidgetTester tester, String label) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(412, 917),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 266,
              child: RouteXSocialButton(
                icon: const Icon(Icons.g_mobiledata),
                label: label,
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('a short label shows in full', (tester) async {
    await _pump(tester, 'Continue with Google');
    expect(tester.takeException(), isNull);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('a very long label is cut instead of overflowing', (tester) async {
    await _pump(
      tester,
      'Continue with your Google account to sign in to RouteX right now',
    );
    expect(tester.takeException(), isNull);
    final text = tester.widget<Text>(find.byType(Text));
    expect(text.overflow, TextOverflow.ellipsis);
    expect(text.maxLines, 1);
  });
}
