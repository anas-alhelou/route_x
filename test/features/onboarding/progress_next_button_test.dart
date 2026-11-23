import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/onboarding/presentation/widgets/progress_next_button.dart';

const _designSize = Size(412, 917);

void main() {
  testWidgets('tapping the Next button advances the PageController',
      (tester) async {
    final pageController = PageController();
    addTearDown(pageController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ScreenUtilInit(
          designSize: _designSize,
          builder: (context, child) => Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: pageController,
                    children: const [ColoredBox(color: Colors.red), ColoredBox(color: Colors.blue)],
                  ),
                ),
                ProgressNextButton(
                  label: 'Next',
                  progress: 0.5,
                  targetProgress: 1,
                  onPressed: () => pageController.nextPage(
                    duration: const Duration(milliseconds: 1),
                    curve: Curves.linear,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(pageController.page, 0);

    await tester.tap(find.byType(ProgressNextButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(pageController.page, 1);
  });

  testWidgets('calls onPressed immediately on tap, alongside the ring animation',
      (tester) async {
    var pressCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ScreenUtilInit(
          designSize: _designSize,
          builder: (context, child) => Scaffold(
            body: ProgressNextButton(
              label: 'Next',
              progress: 0.5,
              targetProgress: 1,
              onPressed: () => pressCount++,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(ProgressNextButton));
    // onPressed fires in the same handler as the ring animation kickoff,
    // so it should already have run before the ring animation settles.
    expect(pressCount, 1);

    await tester.pump(const Duration(milliseconds: 500));
  });
}
