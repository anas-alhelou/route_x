import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/features/auth/presentation/widgets/otp_code_input_row.dart';

const String _sentinel = '\u200B';

Widget _host(
  TextEditingController controller,
  ValueChanged<String> onChanged, {
  int epoch = 0,
}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, _) => MaterialApp(
      home: Scaffold(
        body: OtpCodeInputRow(
          controller: controller,
          onChanged: onChanged,
          resetEpoch: epoch,
        ),
      ),
    ),
  );
}

Finder _box(int i) => find.byType(TextField).at(i);

String _text(WidgetTester t, int i) =>
    t.widget<TextField>(_box(i)).controller!.text.replaceAll(_sentinel, '');

bool _focused(WidgetTester t, int i) =>
    t.widget<TextField>(_box(i)).focusNode!.hasFocus;

void main() {
  late TextEditingController parent;
  late List<String> codes;

  setUp(() {
    parent = TextEditingController();
    codes = [];
  });
  tearDown(() => parent.dispose());

  Future<void> typeThree(WidgetTester tester) async {
    await tester.pumpWidget(_host(parent, codes.add));
    await tester.tap(_box(0));
    await tester.pump();
    await tester.enterText(_box(0), '1');
    await tester.pump();
    await tester.enterText(_box(1), '2');
    await tester.pump();
    await tester.enterText(_box(2), '3');
    await tester.pump();
    expect(_focused(tester, 3), isTrue);
  }

  testWidgets('soft backspace on an empty box clears the previous digit once', (
    tester,
  ) async {
    await typeThree(tester);

    // Box 3 is empty; a soft keyboard deletes its sentinel.
    await tester.enterText(_box(3), '');
    await tester.pump();

    expect(_text(tester, 2), '');
    expect(_text(tester, 1), '2');
    expect(_focused(tester, 2), isTrue);
    expect(codes.last, '12');
  });

  testWidgets('soft backspace on a filled box clears it and keeps focus', (
    tester,
  ) async {
    await typeThree(tester);
    await tester.tap(_box(1));
    await tester.pump();

    await tester.enterText(_box(1), '');
    await tester.pump();

    expect(_text(tester, 1), '');
    expect(_text(tester, 0), '1');
    expect(_focused(tester, 1), isTrue);
    expect(codes.last, '13');
  });

  testWidgets('hardware backspace on an empty box clears previous once', (
    tester,
  ) async {
    await typeThree(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();

    expect(_text(tester, 2), '');
    expect(_text(tester, 1), '2');
    expect(_focused(tester, 2), isTrue);
    expect(codes.last, '12');
  });

  testWidgets('changing resetEpoch clears all boxes and focuses the first', (
    tester,
  ) async {
    await typeThree(tester);
    final before = codes.length;

    await tester.pumpWidget(_host(parent, codes.add, epoch: 1));
    await tester.pump();
    await tester.pump();

    for (var i = 0; i < 6; i++) {
      expect(_text(tester, i), '');
    }
    expect(_focused(tester, 0), isTrue);
    expect(codes.length, before, reason: 'a reset is not a user edit');
  });
}
