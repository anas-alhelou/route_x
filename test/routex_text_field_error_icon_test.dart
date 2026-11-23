import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/l10n/app_localizations.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/widgets/routex_form_scope.dart';
import 'package:routex_mobile/core/widgets/routex_text_field.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/auth_password_form_view.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/vehicle_type_selector.dart';

/// The border a single-line field actually paints: it is drawn by the 56pt box
/// around the input, not by the input's own decoration.
BorderSide paintedBorder(WidgetTester tester) {
  final box = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(RouteXTextField),
          matching: find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration as BoxDecoration).border != null,
          ),
        )
        .first,
  );
  return ((box.decoration as BoxDecoration).border as Border).top;
}

void main() {
  Widget wrap(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(400, 800),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  void usePhoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Widget fieldHost({
    required GlobalKey<FormState> formKey,
    required Widget child,
  }) {
    return wrap(
      Form(
        key: formKey,
        child: Column(
          children: [
            child,
            ElevatedButton(
              onPressed: () => formKey.currentState?.validate(),
              child: const Text('submit'),
            ),
          ],
        ),
      ),
    );
  }

  group('RouteXTextField error presentation', () {
    testWidgets('renders the custom error row and red border after submit', (
      tester,
    ) async {
      usePhoneSurface(tester);
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        fieldHost(
          formKey: formKey,
          child: RouteXTextField(
            hintText: 'Email',
            prefixIcon: const Icon(Icons.email_outlined),
            validator: (value) => (value ?? '').isEmpty ? 'Required' : null,
          ),
        ),
      );

      expect(find.byIcon(Icons.priority_high), findsNothing);
      expect(find.text('Required'), findsNothing);

      await tester.tap(find.text('submit'));
      await tester.pump();
      await tester.pump();

      // Custom red dot + message, in the error color.
      expect(find.byIcon(Icons.priority_high), findsOneWidget);
      final dot = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.priority_high),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((dot.decoration! as BoxDecoration).color, AppColors.textError);
      expect(
        visibleErrorText(tester, 'Required')?.style?.color,
        AppColors.textError,
      );

      // Flutter's own error text is collapsed to zero size.
      final builtIn = tester.widgetList<Text>(
        find.descendant(
          of: find.byType(TextField),
          matching: find.text('Required'),
        ),
      );
      expect(builtIn, isNotEmpty);
      expect(builtIn.every((text) => text.style?.fontSize == 0), isTrue);

      // No error glyph is injected into the field's prefix slot.
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('keeps the error until the next submit, then clears it', (
      tester,
    ) async {
      usePhoneSurface(tester);
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        fieldHost(
          formKey: formKey,
          child: RouteXTextField(
            hintText: 'Email',
            prefixIcon: const Icon(Icons.email_outlined),
            validator: (value) => (value ?? '').isEmpty ? 'Required' : null,
          ),
        ),
      );

      await tester.tap(find.text('submit'));
      await tester.pump();
      await tester.pump();
      expect(find.byIcon(Icons.priority_high), findsOneWidget);

      // No RouteXFormScope here, so nothing is watching the focus: fixing the
      // value does not clear a message that is already on screen. Errors are
      // submit-driven, and only a submit (or a focus, when the form is scoped)
      // takes them away.
      await tester.enterText(find.byType(TextFormField), 'user@example.com');
      await tester.pump();
      await tester.pump();
      expect(find.byIcon(Icons.priority_high), findsOneWidget);

      // The next submit re-runs the validator, and the red treatment — dot,
      // message and prefix tint — is gone.
      await tester.tap(find.text('submit'));
      await tester.pump();
      await tester.pump();
      expect(find.byIcon(Icons.priority_high), findsNothing);
      expect(find.text('Required'), findsNothing);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('shows no error while typing, only after submit', (
      tester,
    ) async {
      usePhoneSurface(tester);
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        fieldHost(
          formKey: formKey,
          child: RouteXTextField(
            hintText: 'First name',
            validator: (value) => (value ?? '').length < 3 ? 'Too short' : null,
          ),
        ),
      );

      // The default is AutovalidateMode.disabled, so an invalid value is never
      // reported until the user actually tries to submit.
      await tester.enterText(find.byType(TextFormField), 'Jo');
      await tester.pump();
      await tester.pump();
      expect(find.byIcon(Icons.priority_high), findsNothing);
      expect(visibleErrorText(tester, 'Too short'), isNull);

      await tester.tap(find.text('submit'));
      await tester.pump();
      await tester.pump();
      expect(find.byIcon(Icons.priority_high), findsOneWidget);
      expect(visibleErrorText(tester, 'Too short'), isNotNull);
    });

    testWidgets('validates live when the field opts into user interaction', (
      tester,
    ) async {
      usePhoneSurface(tester);

      await tester.pumpWidget(
        wrap(
          RouteXTextField(
            hintText: 'Email',
            // The capability itself is still supported by the widget; the auth
            // screens simply no longer turn it on, because focusing any field
            // now clears the whole form's errors (see the RouteXFormScope
            // tests below).
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) =>
                (value ?? '').contains('@') ? null : 'Enter a valid email',
          ),
        ),
      );

      expect(find.byIcon(Icons.priority_high), findsNothing);

      // No submit press: just type an invalid value, then a valid one.
      await tester.enterText(find.byType(TextFormField), 'not-an-email');
      await tester.pump();
      await tester.pump();
      expect(find.byIcon(Icons.priority_high), findsOneWidget);
      expect(visibleErrorText(tester, 'Enter a valid email'), isNotNull);

      await tester.enterText(find.byType(TextFormField), 'user@example.com');
      await tester.pump();
      await tester.pump();
      expect(find.byIcon(Icons.priority_high), findsNothing);
    });

    testWidgets('tints an existing prefix icon red while invalid', (
      tester,
    ) async {
      usePhoneSurface(tester);
      final formKey = GlobalKey<FormState>();
      final boundaryKey = GlobalKey();

      // A solid round prefix icon makes the rendered tint measurable.
      await tester.pumpWidget(
        fieldHost(
          formKey: formKey,
          child: RepaintBoundary(
            key: boundaryKey,
            child: RouteXTextField(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.circle, size: 20),
              validator: _alwaysInvalid,
            ),
          ),
        ),
      );

      // Reads what the prefix glyph is actually painted in, so the assertion is
      // about rendered output rather than widget properties.
      Future<Color?> iconTint() => dominantIconColor(
        tester,
        boundaryKey,
        tester.getRect(find.byIcon(Icons.circle)),
      );

      BorderSide border() => paintedBorder(tester);

      // Idle: neutral.
      expect(await iconTint(), AppColors.iconHint);
      expect(border().color, AppColors.borderDeactivated);

      await tester.tap(find.text('submit'));
      await tester.pump();
      await tester.pump();

      // Invalid and not focused: red icon + red border, message row shown.
      expect(await iconTint(), AppColors.textError);
      expect(border().color, AppColors.textError);
      expect(find.byIcon(Icons.priority_high), findsOneWidget);

      // Focused: the green active color wins over the error.
      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      expect(await iconTint(), AppColors.brandMain);
      expect(border().color, AppColors.brandMain);

      // Leaving an invalid field brings the red treatment back.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(await iconTint(), AppColors.textError);
      expect(border().color, AppColors.textError);
    });

    testWidgets('focus wins over error for the border color', (tester) async {
      usePhoneSurface(tester);
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        fieldHost(
          formKey: formKey,
          child: RouteXTextField(
            hintText: 'First name',
            validator: _alwaysInvalid,
          ),
        ),
      );

      BorderSide unfocusedBorder() => paintedBorder(tester);

      // A field with no prefix icon still gets the full red treatment.
      expect(unfocusedBorder().color, AppColors.borderDeactivated);
      expect(find.byType(ColorFiltered), findsNothing);

      await tester.tap(find.text('submit'));
      await tester.pump();
      await tester.pump();
      expect(unfocusedBorder().color, AppColors.textError);
      expect(find.byIcon(Icons.priority_high), findsOneWidget);

      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      expect(unfocusedBorder().color, AppColors.brandMain);

      // Leaving the field restores the red treatment while it is still invalid.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(unfocusedBorder().color, AppColors.textError);
    });
  });

  group('RouteXFormScope clears every field on focus', () {
    final formKey = GlobalKey<FormState>();

    Widget twoFieldHost() => wrap(
      RouteXFormScope(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              RouteXTextField(
                key: const ValueKey('first'),
                hintText: 'First name',
                validator: (value) => (value ?? '').isEmpty ? 'Required' : null,
              ),
              RouteXTextField(
                key: const ValueKey('second'),
                hintText: 'Email',
                validator: (value) => (value ?? '').isEmpty ? 'Required' : null,
              ),
              ElevatedButton(
                onPressed: () => formKey.currentState?.validate(),
                child: const Text('submit'),
              ),
            ],
          ),
        ),
      ),
    );

    testWidgets('focusing one field clears the error on the other', (
      tester,
    ) async {
      usePhoneSurface(tester);
      await tester.pumpWidget(twoFieldHost());

      formKey.currentState?.validate();
      await tester.pump();
      await tester.pump();
      // Both fields are empty, so both report.
      expect(find.byIcon(Icons.priority_high), findsNWidgets(2));

      await tester.tap(find.byKey(const ValueKey('second')));
      await tester.pump();
      await tester.pump();

      // Neither the focused field nor its sibling shows a message any more.
      expect(find.byIcon(Icons.priority_high), findsNothing);
      expect(visibleErrorText(tester, 'Required'), isNull);
    });

    testWidgets('a field outside any scope still behaves on submit', (
      tester,
    ) async {
      usePhoneSurface(tester);
      // No RouteXFormScope ancestor: registering must not throw.
      await tester.pumpWidget(
        wrap(
          Form(
            key: formKey,
            child: Column(
              children: [
                RouteXTextField(
                  hintText: 'First name',
                  validator: (value) =>
                      (value ?? '').isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
      );

      formKey.currentState?.validate();
      await tester.pump();
      await tester.pump();
      expect(find.byIcon(Icons.priority_high), findsOneWidget);
    });

    testWidgets('a cleared error is not resurrected by a later validate', (
      tester,
    ) async {
      usePhoneSurface(tester);
      await tester.pumpWidget(twoFieldHost());

      formKey.currentState?.validate();
      await tester.pump();
      await tester.pump();
      expect(find.byIcon(Icons.priority_high), findsNWidgets(2));

      // Focusing clears both...
      await tester.tap(find.byKey(const ValueKey('second')));
      await tester.pump();
      await tester.pump();
      expect(find.byIcon(Icons.priority_high), findsNothing);

      // ...and fixing the focused field's value (which re-runs its validator
      // on the next frame) does not bring the message back.
      await tester.enterText(find.byKey(const ValueKey('second')), 'a@b.co');
      await tester.pump();
      await tester.pump();
      expect(find.byIcon(Icons.priority_high), findsNothing);
    });
  });

  group('AuthPasswordFormView confirm-password feedback', () {
    // Signup step 3 and the forgot-password "Set new password" screen share this
    // view, and a mismatch is now reported the same way on both: never as text.
    // The disabled button and the green tick carry the whole signal.
    Future<void> pumpForm(WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        wrap(
          AuthPasswordFormView(
            title: 'Create a',
            titleHighlight: 'secure password',
            subtitle: 'subtitle',
            buttonText: 'Review details',
            onSubmit: () {},
          ),
        ),
      );
    }

    /// The input belonging to the field carrying [label].
    Finder inputLabelled(String label) => find.descendant(
      of: find.ancestor(
        of: find.text(label),
        matching: find.byType(RouteXTextField),
      ),
      matching: find.byType(TextFormField),
    );

    testWidgets('never reports a mismatch while typing', (tester) async {
      await pumpForm(tester);

      await tester.enterText(inputLabelled('Password'), 'Passw0rd!');
      await tester.enterText(inputLabelled('Confirm Password'), 'Mismatch!');
      await tester.pump();
      await tester.pump();

      expect(
        visibleErrorText(tester, 'Passwords do not match'),
        isNull,
        reason: 'the confirmation is not allowed to flash red text',
      );
      expect(find.byIcon(Icons.priority_high), findsNothing);
    });

    testWidgets('never reports a mismatch on an explicit validate', (
      tester,
    ) async {
      await pumpForm(tester);

      await tester.enterText(inputLabelled('Password'), 'Passw0rd!');
      await tester.enterText(inputLabelled('Confirm Password'), 'Mismatch!');
      await tester.pump();
      await tester.pump();

      // The submit handler re-checks the match in the domain instead of
      // displaying it, so even a forced validate() shows nothing.
      tester.state<FormState>(find.byType(Form)).validate();
      await tester.pump();
      await tester.pump();

      expect(visibleErrorText(tester, 'Passwords do not match'), isNull);
      expect(find.byIcon(Icons.priority_high), findsNothing);
    });

    testWidgets('keeps submit disabled until the confirmation matches', (
      tester,
    ) async {
      await pumpForm(tester);

      void submitEnabled() {
        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Review details'),
        );
        expect(button.onPressed, isNotNull, reason: 'submit should be enabled');
      }

      void submitDisabled() {
        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Review details'),
        );
        expect(button.onPressed, isNull, reason: 'submit should be disabled');
      }

      submitDisabled();

      await tester.enterText(inputLabelled('Password'), 'Passw0rd!');
      await tester.pump();
      // Password alone is not enough.
      submitDisabled();

      await tester.enterText(inputLabelled('Confirm Password'), 'Mismatch!');
      await tester.pump();
      submitDisabled();

      await tester.enterText(inputLabelled('Confirm Password'), 'Passw0rd!');
      await tester.pump();
      submitEnabled();
    });

    testWidgets('shows the green tick, and keeps it green when focused', (
      tester,
    ) async {
      await pumpForm(tester);

      await tester.enterText(inputLabelled('Password'), 'Passw0rd!');
      await tester.enterText(inputLabelled('Confirm Password'), 'Passw0rd!');
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(
        tester.widget<Icon>(find.byIcon(Icons.check_circle)).color,
        AppColors.brandMain,
      );

      // The tick is a success indicator, not a field decoration, so focusing
      // must not retint it to the focus/error color.
      await tester.tap(inputLabelled('Confirm Password'));
      await tester.pump();
      await tester.pump();
      expect(
        tester.widget<Icon>(find.byIcon(Icons.check_circle)).color,
        AppColors.brandMain,
      );
    });

    testWidgets('the password field itself never live-validates', (
      tester,
    ) async {
      await pumpForm(tester);

      // Type a password, then empty it. With live validation on, the field
      // would immediately complain that it is required.
      await tester.enterText(inputLabelled('Password'), 'Passw0rd!');
      await tester.pump();
      await tester.enterText(inputLabelled('Password'), '');
      await tester.pump();
      await tester.pump();

      expect(visibleErrorText(tester, 'Password is required'), isNull);
    });
  });

  testWidgets('vehicle selector animates the selected card', (tester) async {
    usePhoneSurface(tester);
    String? selected;

    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: VehicleTypeSelector(
              selectedVehicle: selected,
              onSelected: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check_rounded), findsNWidgets(4));
    expect(_badgeScales(tester), everyElement(0));

    await tester.tap(find.text('Car'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final midFlight = _badgeScales(tester);
    expect(midFlight.where((scale) => scale > 0 && scale < 1), hasLength(1));

    await tester.pumpAndSettle();
    expect(_badgeScales(tester), [0, 1, 0, 0]);
    expect(
      tester
          .widget<AnimatedContainer>(find.byType(AnimatedContainer).first)
          .duration,
      const Duration(milliseconds: 200),
    );
  });
}

List<double> _badgeScales(WidgetTester tester) {
  // Reads the in-flight value from the ScaleTransition that [AnimatedScale]
  // builds, not the target widget property, so progress is observable.
  // Only the selection badges (200ms); each card is also wrapped in the 120ms
  // press-scale of RouteXTapScale, which is not what this test measures.
  final badges = find.byWidgetPredicate(
    (w) =>
        w is AnimatedScale && w.duration == const Duration(milliseconds: 200),
  );
  return [
    for (var i = 0; i < badges.evaluate().length; i++)
      tester
          .widget<ScaleTransition>(
            find.descendant(
              of: badges.at(i),
              matching: find.byType(ScaleTransition),
            ),
          )
          .scale
          .value,
  ];
}

String? _alwaysInvalid(String? value) => 'Required';

/// The visible (non zero-sized) copy of [message], i.e. the custom error row
/// rather than the collapsed text Flutter builds inside the [TextField].
Text? visibleErrorText(WidgetTester tester, String message) {
  for (final text in tester.widgetList<Text>(find.text(message))) {
    if ((text.style?.fontSize ?? 0) > 0) return text;
  }
  return null;
}

/// The color the prefix glyph is actually painted in, read from the pixels of
/// [rect] inside the [RepaintBoundary] identified by [boundaryKey]. Near-white
/// background pixels are ignored, so the result is the solid tint of the icon
/// rather than the surrounding field.
Future<Color?> dominantIconColor(
  WidgetTester tester,
  GlobalKey boundaryKey,
  Rect rect,
) async {
  // Rasterization needs the real event loop, hence runAsync.
  final packed = await tester.runAsync(() async {
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.0);
    final data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final topLeft = boundary.globalToLocal(rect.topLeft);
    final bottomRight = boundary.globalToLocal(rect.bottomRight);
    final counts = <int, int>{};
    for (var y = topLeft.dy.floor(); y <= bottomRight.dy.ceil(); y++) {
      if (y < 0 || y >= image.height) continue;
      for (var x = topLeft.dx.floor(); x <= bottomRight.dx.ceil(); x++) {
        if (x < 0 || x >= image.width) continue;
        final offset = (y * image.width + x) * 4;
        final r = data.getUint8(offset);
        final g = data.getUint8(offset + 1);
        final b = data.getUint8(offset + 2);
        // Skip the field background and antialiased near-background edges.
        if (r > 240 && g > 240 && b > 240) continue;
        final key = (r << 16) | (g << 8) | b;
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  });
  if (packed == null) return null;
  return Color(0xFF000000 | packed);
}
