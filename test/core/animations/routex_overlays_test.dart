import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';
import 'package:routex_mobile/core/motion.dart';

/// A page with one plain tap target (no ink splash, so nothing but the overlay
/// itself is animating) that runs [onOpen] when tapped.
Widget _app({
  required Future<void> Function(BuildContext context) onOpen,
  bool reduceMotion = false,
}) {
  return MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: child!,
    ),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: GestureDetector(
            onTap: () => onOpen(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

Widget _dialogBody(BuildContext context) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Dialog body'),
            GestureDetector(
              onTap: () => Navigator.of(context).pop('ok'),
              child: const Text('confirm'),
            ),
          ],
        ),
      ),
    );

Widget _sheetBody(BuildContext context) => SizedBox(
      height: 120,
      child: Center(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop('done'),
          child: const Text('Sheet body'),
        ),
      ),
    );

void main() {
  group('showRoutexDialog', () {
    testWidgets('shows the dialog and returns what it pops with',
        (tester) async {
      String? result;
      await tester.pumpWidget(_app(onOpen: (context) async {
        result = await showRoutexDialog<String>(
          context: context,
          builder: _dialogBody,
        );
      }));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Dialog body'), findsOneWidget);

      await tester.tap(find.text('confirm'));
      await tester.pumpAndSettle();
      expect(find.text('Dialog body'), findsNothing);
      expect(result, 'ok');
    });

    testWidgets('a tap on the scrim closes it when it is dismissible',
        (tester) async {
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showRoutexDialog<void>(context: context, builder: _dialogBody);
      }));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.text('Dialog body'), findsNothing);
    });

    testWidgets('a tap on the scrim keeps it when barrierDismissible is false',
        (tester) async {
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showRoutexDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: _dialogBody,
        );
      }));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.text('Dialog body'), findsOneWidget);
    });

    testWidgets('grows from 96% of its size and ends at full size',
        (tester) async {
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showRoutexDialog<void>(context: context, builder: _dialogBody);
      }));
      await tester.tap(find.text('open'));
      await tester.pump(); // first frame of the route

      final scale = find.ancestor(
        of: find.byType(Dialog),
        matching: find.byType(ScaleTransition),
      );
      expect(scale, findsOneWidget);
      expect(
        tester.widget<ScaleTransition>(scale).scale.value,
        closeTo(Motion.dialogStartScale, 0.01),
      );

      await tester.pumpAndSettle();
      expect(tester.widget<ScaleTransition>(scale).scale.value, 1.0);
    });

    testWidgets('with reduced motion it only fades and settles quickly',
        (tester) async {
      await tester.pumpWidget(_app(
        reduceMotion: true,
        onOpen: (context) async {
          await showRoutexDialog<void>(context: context, builder: _dialogBody);
        },
      ));
      await tester.tap(find.text('open'));
      await tester.pump();
      // No scale at all: nothing travels or grows.
      expect(
        find.ancestor(
          of: find.byType(Dialog),
          matching: find.byType(ScaleTransition),
        ),
        findsNothing,
      );

      await tester.pump(Motion.reduced + const Duration(milliseconds: 1));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('without reduced motion it is still animating after 120ms',
        (tester) async {
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showRoutexDialog<void>(context: context, builder: _dialogBody);
      }));
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(Motion.reduced + const Duration(milliseconds: 1));
      expect(tester.hasRunningAnimations, isTrue);
    });
  });

  group('showRoutexSheet', () {
    testWidgets('shows the sheet and returns what it pops with',
        (tester) async {
      String? result;
      await tester.pumpWidget(_app(onOpen: (context) async {
        result = await showRoutexSheet<String>(
          context: context,
          builder: _sheetBody,
        );
      }));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsOneWidget);

      await tester.tap(find.text('Sheet body'));
      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsNothing);
      expect(result, 'done');
    });

    testWidgets('can be dragged down to dismiss, like a normal sheet',
        (tester) async {
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showRoutexSheet<void>(context: context, builder: _sheetBody);
      }));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.fling(find.text('Sheet body'), const Offset(0, 400), 1500);
      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsNothing);
    });

    testWidgets('enableDrag: false keeps it open on a drag', (tester) async {
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showRoutexSheet<void>(
          context: context,
          enableDrag: false,
          builder: _sheetBody,
        );
      }));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.fling(find.text('Sheet body'), const Offset(0, 400), 1500);
      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsOneWidget);
    });

    testWidgets('with reduced motion it settles within the short duration',
        (tester) async {
      await tester.pumpWidget(_app(
        reduceMotion: true,
        onOpen: (context) async {
          await showRoutexSheet<void>(context: context, builder: _sheetBody);
        },
      ));
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(Motion.reduced + const Duration(milliseconds: 1));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('without reduced motion it is still moving after 120ms',
        (tester) async {
      await tester.pumpWidget(_app(onOpen: (context) async {
        await showRoutexSheet<void>(context: context, builder: _sheetBody);
      }));
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(Motion.reduced + const Duration(milliseconds: 1));
      expect(tester.hasRunningAnimations, isTrue);
    });
  });
}
