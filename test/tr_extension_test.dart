import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/network/exception_mapper.dart';

void main() {
  group('translateValidationKey', () {
    testWidgets('translates a known internal validation key', (tester) async {
      final context = await _pump(tester);
      expect(context.tr.errEmailInvalid, 'Enter a valid email address');
      expect(
        context.translateValidationKey('errEmailInvalid'),
        'Enter a valid email address',
      );
    });

    testWidgets('translates every key the AuthValidators can emit', (
      tester,
    ) async {
      final context = await _pump(tester);

      // Each of these is returned verbatim by AuthValidators; none may fall
      // through to the default branch.
      const validatorKeys = [
        'errNameRequired',
        'errNameMinLength',
        'errFirstNameRequired',
        'errFirstNameMinLength',
        'errLastNameRequired',
        'errLastNameMinLength',
        'errEmailRequired',
        'errEmailInvalid',
        'errPhoneRequired',
        'errPhoneInvalid',
        'errPasswordRequired',
        'errPasswordMismatch',
        'errPasswordMinLength',
        'errPasswordUppercase',
        'errPasswordLowercase',
        'errPasswordNumber',
        'errPasswordSymbol',
        'errOtpRequired',
        'errOtpInvalid',
        'errVehicleRequired',
        'errResetTokenRequired',
      ];

      for (final key in validatorKeys) {
        final translated = context.translateValidationKey(key);
        expect(
          translated,
          isNot(key),
          reason:
              '$key fell through to the default branch and was not localized',
        );
        expect(translated, isNotEmpty);
      }
    });

    testWidgets('returns an unknown backend message unchanged', (tester) async {
      final context = await _pump(tester);

      // These are the strings ExceptionMapper lifts out of the API error
      // envelope into Failure.message. They must survive to the UI verbatim.
      const backendMessages = [
        'Invalid credentials',
        'Email is already registered',
        'نوع المركبة غير مدعوم',
        'Bad Request',
        'Something went wrong.',
        'password must be longer than or equal to 8 characters',
      ];

      for (final message in backendMessages) {
        expect(
          context.translateValidationKey(message),
          message,
          reason: 'a real API message must not be replaced by a generic string',
        );
      }
    });

    testWidgets('does not fall back to the generic string for an API error', (
      tester,
    ) async {
      final context = await _pump(tester);
      const generic = 'Something went wrong.';

      // The regression this guards: a real register failure used to surface as
      // the generic string, hiding "نوع المركبة غير مدعوم" from the user.
      final shown = context.translateValidationKey('نوع المركبة غير مدعوم');

      expect(shown, isNot(generic));
      expect(shown, 'نوع المركبة غير مدعوم');
    });

    testWidgets('translates known keys in Arabic too', (tester) async {
      final context = await _pump(tester, locale: const Locale('ar'));

      final arabic = context.translateValidationKey('errEmailInvalid');
      expect(arabic, isNot('errEmailInvalid'));
      expect(arabic, isNotEmpty);

      // Still verbatim for backend messages, in either language.
      expect(
        context.translateValidationKey('Invalid credentials'),
        'Invalid credentials',
      );
    });

    testWidgets('translates the failure keys raised outside the UI', (
      tester,
    ) async {
      final context = await _pump(tester);

      // NetworkFailure and the two Google failures name themselves with a key
      // because they are constructed in the data layer, where no BuildContext
      // exists. Every display path runs translateValidationKey, so a missing
      // case here would put a raw key on the screen.
      const dataLayerKeys = [
        'errNoInternetConnection',
        'errGoogleNotConfigured',
        'errGoogleSignInFailed',
      ];

      for (final key in dataLayerKeys) {
        final translated = context.translateValidationKey(key);
        expect(
          translated,
          isNot(key),
          reason: '$key reached the screen untranslated',
        );
        expect(translated, isNotEmpty);
      }
    });

    testWidgets('the data layer failure keys are localized in Arabic', (
      tester,
    ) async {
      final context = await _pump(tester, locale: const Locale('ar'));

      // The default NetworkFailure message used to be the literal English
      // string 'No internet connection', which is exactly what this guards.
      final noInternet = context.translateValidationKey(
        'errNoInternetConnection',
      );
      expect(noInternet, isNot('errNoInternetConnection'));
      expect(noInternet, isNot('No internet connection'));
      expect(noInternet, isNotEmpty);
    });

    testWidgets('the three Google outcomes are distinguishable', (
      tester,
    ) async {
      final context = await _pump(tester);

      // A screenshot of the login page has to say which stage broke, so none of
      // these may collapse into the same sentence.
      final messages = {
        'errGoogleNotConfigured': context.translateValidationKey(
          'errGoogleNotConfigured',
        ),
        'errNoInternetConnection': context.translateValidationKey(
          'errNoInternetConnection',
        ),
        'errGoogleSignInFailed': context.translateValidationKey(
          'errGoogleSignInFailed',
        ),
        ExceptionMapper.unexpectedErrorKey: context.translateValidationKey(
          ExceptionMapper.unexpectedErrorKey,
        ),
      };

      expect(messages.values.toSet(), hasLength(messages.length));
    });
  });
}

/// Pumps a minimal localized app and returns a context that can reach `tr`.
Future<BuildContext> _pump(WidgetTester tester, {Locale? locale}) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          captured = context;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return captured;
}
