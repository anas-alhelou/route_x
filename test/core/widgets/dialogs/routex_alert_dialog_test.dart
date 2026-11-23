import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/dialogs/discard_changes_dialog.dart';
import 'package:routex_mobile/core/widgets/dialogs/email_confirmation_dialog.dart';
import 'package:routex_mobile/core/widgets/dialogs/enable_location_dialog.dart';
import 'package:routex_mobile/core/widgets/dialogs/error_alert_dialog.dart';
import 'package:routex_mobile/core/widgets/dialogs/logout_dialog.dart';
import 'package:routex_mobile/core/widgets/dialogs/profile_updated_dialog.dart';
import 'package:routex_mobile/core/widgets/dialogs/routex_alert_dialog.dart';
import 'package:routex_mobile/core/widgets/dialogs/session_expired_dialog.dart';
import 'package:routex_mobile/core/widgets/routex_error_dialog.dart';

/// Smallest surface the app is expected to run on. Every case below is pumped
/// here as well as on the 412x917 design size.
const Size _compact = Size(320, 568);
const Size _design = Size(412, 917);

/// Pumps [onOpen] behind a launcher button so each dialog is opened through a
/// real [Navigator] route, exactly as it is in the app.
Widget host(
  void Function(BuildContext) onOpen, {
  required Locale locale,
}) {
  return ScreenUtilInit(
    designSize: _design,
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => onOpen(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  void useSurface(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  /// Opens the dialog behind the launcher and asserts the layout settled
  /// without a RenderFlex overflow, which the framework reports as an exception.
  Future<void> openAndSettle(
    WidgetTester tester,
    Widget widget,
    Size size,
  ) async {
    useSurface(tester, size);
    await tester.pumpWidget(widget);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  group('RouteXAlertDialog layout', () {
    /// Longest real copy in the family, so wrapping is exercised rather than
    /// assumed. (title, message) pairs drawn from the Figma frames.
    const copy = <({String title, String message})>[
      (
        title: 'Something went wrong',
        message: 'We couldn\'t complete your request. Please try again.',
      ),
      (
        title: 'Discard changes?',
        message: 'If you leave now, your edits will be lost.',
      ),
      (
        title: 'Confirm your email',
        message: 'Please make sure this email is correct. We\'ll send a '
            'verification code to:',
      ),
      (
        title: 'Session expired',
        message: 'For your security, please sign in again.',
      ),
    ];

    for (final locale in const [Locale('en'), Locale('ar')]) {
      for (final size in const [_compact, _design]) {
        testWidgets(
          'no overflow at ${size.width.toInt()}x${size.height.toInt()} '
          'in ${locale.languageCode}',
          (tester) async {
            useSurface(tester, size);

            // Pumped one at a time so one card cannot mask the next.
            for (final entry in copy) {
              await tester.pumpWidget(
                host(
                  (context) => RouteXAlertDialog.show(
                    context: context,
                    title: entry.title,
                    message: entry.message,
                    icon: Icons.cancel,
                    iconColor: AppColors.iconRed,
                    iconBackgroundColor: AppColors.iconWarning,
                    cancelLabel: 'Cancel',
                    confirmLabel: 'Continue',
                  ),
                  locale: locale,
                ),
              );
              await tester.tap(find.text('open'));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              await tester.tap(find.text('Cancel'));
              await tester.pumpAndSettle();
            }
          },
        );

        testWidgets(
          'inline alert fits and stays on the leading edge '
          'in ${locale.languageCode} at ${size.width.toInt()}'
          'x${size.height.toInt()}',
          (tester) async {
            await openAndSettle(
              tester,
              host(
                (context) => RouteXAlertDialog.show(
                  context: context,
                  title: 'Session expired',
                  message: 'For your security, please sign in again.',
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.brandSecondary,
                  layout: RouteXAlertLayout.inline,
                  confirmLabel: 'Sign in',
                ),
                locale: locale,
              ),
              size,
            );

            final badge = tester.getRect(
              find.byIcon(Icons.info_outline_rounded),
            );
            final title = tester.getRect(find.text('Session expired'));
            if (locale.languageCode == 'ar') {
              // Arabic reads right to left, so the badge leads on the right.
              expect(badge.left, greaterThan(title.left));
            } else {
              expect(badge.right, lessThan(title.left));
            }

            await tester.tap(find.text('Sign in'));
            await tester.pumpAndSettle();
          },
        );
      }
    }

    testWidgets('a non-dismissible alert ignores the scrim and back button', (
      tester,
    ) async {
      await openAndSettle(
        tester,
        host(
          (context) => SessionExpiredDialog.show(context: context),
          locale: const Locale('en'),
        ),
        _design,
      );

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(find.text('Session expired'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Session expired'), findsOneWidget);

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Session expired'), findsNothing);
    });

    testWidgets('the detail plate is capped rather than clipped', (
      tester,
    ) async {
      await openAndSettle(
        tester,
        host(
          (context) => RouteXAlertDialog.show(
            context: context,
            title: 'Confirm your email',
            message: 'Please make sure this email is correct.',
            detail: 'a.very.long.address.that.overflows@subdomain.example.com',
            icon: Icons.mark_email_read,
            iconColor: AppColors.brandSecondary,
            cancelLabel: 'Cancel',
            confirmLabel: 'Send code',
          ),
          locale: const Locale('en'),
        ),
        _compact,
      );

      expect(tester.takeException(), isNull);
      expect(
        find.text('a.very.long.address.that.overflows@subdomain.example.com'),
        findsOneWidget,
      );
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
    });
  });

  group('dialog contracts', () {
    testWidgets('ErrorAlertDialog resolves true on retry', (tester) async {
      bool? answer;

      await openAndSettle(
        tester,
        host(
          (context) async {
            answer = await context.showErrorAlertDialog();
          },
          locale: const Locale('en'),
        ),
        _design,
      );

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(answer, isTrue);
    });

    testWidgets('ErrorAlertDialog resolves false on cancel', (tester) async {
      bool? answer;

      await openAndSettle(
        tester,
        host(
          (context) async {
            answer = await context.showErrorAlertDialog();
          },
          locale: const Locale('en'),
        ),
        _design,
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(answer, isFalse);
    });

    testWidgets('EmailConfirmationDialog echoes the address back', (
      tester,
    ) async {
      await openAndSettle(
        tester,
        host(
          (context) => context.showEmailConfirmationDialog(
            email: 'hbarakat3@gmail.com',
          ),
          locale: const Locale('en'),
        ),
        _design,
      );

      expect(find.text('hbarakat3@gmail.com'), findsOneWidget);
      expect(find.text('Send code'), findsOneWidget);

      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
    });

    testWidgets('ProfileUpdatedDialog copy', (tester) async {
      useSurface(tester, _design);
      await tester.pumpWidget(host((_) {}, locale: const Locale('en')));
      final tr = AppLocalizations.of(
        tester.element(find.byType(Scaffold).first),
      )!;

      // `show` only completes once the dialog is dismissed, so it must not be
      // awaited before the action tap below.
      ProfileUpdatedDialog.show(
        context: tester.element(find.byType(Scaffold).first),
      );
      await tester.pumpAndSettle();

      expect(find.text(tr.profileUpdatedTitle), findsOneWidget);
      expect(find.text(tr.profileUpdatedMessage), findsOneWidget);
      expect(find.text(tr.done), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(tr.done));
      await tester.pumpAndSettle();
    });

    testWidgets('DiscardChangesDialog copy', (tester) async {
      useSurface(tester, _design);
      await tester.pumpWidget(host((_) {}, locale: const Locale('en')));
      final tr = AppLocalizations.of(
        tester.element(find.byType(Scaffold).first),
      )!;

      DiscardChangesDialog.show(
        context: tester.element(find.byType(Scaffold).first),
      );
      await tester.pumpAndSettle();

      expect(find.text(tr.discardChangesTitle), findsOneWidget);
      expect(find.text(tr.discardChangesMessage), findsOneWidget);
      expect(find.text(tr.discard), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(tr.discard));
      await tester.pumpAndSettle();
    });

    testWidgets('LogoutDialog copy', (tester) async {
      useSurface(tester, _design);
      await tester.pumpWidget(host((_) {}, locale: const Locale('en')));
      final tr = AppLocalizations.of(
        tester.element(find.byType(Scaffold).first),
      )!;

      LogoutDialog.show(
        context: tester.element(find.byType(Scaffold).first),
      );
      await tester.pumpAndSettle();

      expect(find.text(tr.logOutTitle), findsOneWidget);
      expect(find.text(tr.logOutMessage), findsOneWidget);
      expect(find.text(tr.logOut), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(tr.logOut));
      await tester.pumpAndSettle();
    });

    testWidgets('EnableLocationDialog copy', (tester) async {
      useSurface(tester, _design);
      await tester.pumpWidget(host((_) {}, locale: const Locale('en')));
      final tr = AppLocalizations.of(
        tester.element(find.byType(Scaffold).first),
      )!;

      EnableLocationDialog.show(
        context: tester.element(find.byType(Scaffold).first),
      );
      await tester.pumpAndSettle();

      expect(find.text(tr.enableLocationTitle), findsOneWidget);
      expect(find.text(tr.enableLocationMessage), findsOneWidget);
      expect(find.text(tr.allowAccess), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(tr.allowAccess));
      await tester.pumpAndSettle();
    });

    testWidgets('RouteXErrorDialog copy', (tester) async {
      useSurface(tester, _design);
      await tester.pumpWidget(host((_) {}, locale: const Locale('en')));
      final tr = AppLocalizations.of(
        tester.element(find.byType(Scaffold).first),
      )!;

      RouteXErrorDialog.show(
        context: tester.element(find.byType(Scaffold).first),
        message: 'boom',
      );
      await tester.pumpAndSettle();

      expect(find.text('boom'), findsOneWidget);
      expect(find.text(tr.errorAlertTitle), findsOneWidget);
      expect(find.text(tr.done), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(tr.done));
      await tester.pumpAndSettle();
    });
  });
}
