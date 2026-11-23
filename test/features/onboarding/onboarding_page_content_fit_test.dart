import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/config/constants/app_assets.dart';
import 'package:routex_mobile/features/onboarding/presentation/widgets/onboarding_page_content.dart';

final _page = OnboardingSlideData(
  imageAssetPath: AppAssets.imgOnboarding1,
  titleSegments: [
    OnboardingTextSegment('Deliver '),
    OnboardingTextSegment('More. ', isHighlighted: true),
    OnboardingTextSegment('Drive '),
    OnboardingTextSegment('Less.', isHighlighted: true),
  ],
  subtitle: 'Smarter routes, fewer miles. Better results for your business.',
);

Future<void> _pump(WidgetTester tester, Size area) async {
  // ScreenUtil scales from the real view, so the view itself must be the size
  // under test (not just a box inside a larger window).
  tester.view.physicalSize = area;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(412, 917),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: area.width,
            height: area.height,
            child: OnboardingPageContent(page: _page),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  // Lets flutter_animate's zero-delay start timer fire before the test ends.
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('a short screen does not overflow: the image gives way',
      (tester) async {
    await _pump(tester, const Size(360, 475));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a roomy screen keeps the image at its natural height',
      (tester) async {
    await _pump(tester, const Size(412, 1400));
    expect(tester.takeException(), isNull);
    final image = tester.getSize(find
        .descendant(
          of: find.descendant(
            of: find.byType(OnboardingPageContent),
            matching: find.byType(LayoutBuilder),
          ),
          matching: find.byType(SizedBox),
        )
        .first);
    expect(image.height, closeTo(412 / (1236 / 1590), 0.5));
  });
}
