import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tum/core/theme/app_text_styles.dart';

/// Real body from poetry_catalog row 954e52b2-6c84-4298-8332-d6639b05d754.
const dbBody =
    '\u0632\u0646\u062f\u0627\u0646 \u06cc\u0648\u0633\u0641 \u0646\u06c1 \u0633\u06c1\u06cc \u0648\u0642\u062a \u06a9\u06cc \u062f\u0633\u062a\u0631\u0633 \u0645\u06cc\u06ba \u06c1\u06d2\n'
    '\u0645\u06cc\u06ba \u0628\u0633 \u0627\u062a\u0646\u0627 \u062c\u0627\u0646\u062a\u0627 \u06c1\u0648\u06ba \u06a9\u06c1 \u06c1\u0631 \u0622\u062f\u0645\u06cc \u0642\u0641\u0633 \u0645\u06cc\u06ba \u06c1\u06d2';

const rtlArrowKeys = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.arrowLeft):
      ExtendSelectionByCharacterIntent(forward: true, collapseSelection: true),
  SingleActivator(LogicalKeyboardKey.arrowRight):
      ExtendSelectionByCharacterIntent(forward: false, collapseSelection: true),
};

Widget appEditor(TextEditingController c, FocusNode f, {bool withFix = true}) {
  final field = TextField(
    controller: c,
    focusNode: f,
    maxLines: null,
    textAlign: TextAlign.start,
    textDirection: TextDirection.rtl,
    keyboardType: TextInputType.multiline,
    autocorrect: false,
    enableSuggestions: false,
    style: AppTextStyles.urduEditor(fontSize: 22, height: 1.85),
    decoration: const InputDecoration(border: InputBorder.none),
  );
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 320,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: withFix
                ? Shortcuts(shortcuts: rtlArrowKeys, child: field)
                : field,
          ),
        ),
      ),
    ),
  );
}

double caretX(int offset) {
  final tp = TextPainter(
    text: TextSpan(
      text: dbBody.substring(0, 10),
      style: AppTextStyles.urduEditor(fontSize: 22, height: 1.85),
    ),
    textDirection: TextDirection.rtl,
    textAlign: TextAlign.start,
  )..layout(maxWidth: 320);
  return tp.getOffsetForCaret(TextPosition(offset: offset), Rect.zero).dx;
}

void main() {
  testWidgets('arrow keys move the caret in the direction the user pressed',
      (tester) async {
    for (final withFix in [false, true]) {
      final c = TextEditingController(text: dbBody);
      final f = FocusNode();
      await tester.pumpWidget(appEditor(c, f, withFix: withFix));
      f.requestFocus();

      c.selection = const TextSelection.collapsed(offset: 5);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      final left = c.selection.extentOffset;

      c.selection = const TextSelection.collapsed(offset: 5);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      final right = c.selection.extentOffset;

      debugPrint('withFix=$withFix  caretX(5)=${caretX(5).toStringAsFixed(0)}');
      debugPrint('   arrowLeft  -> offset $left  x=${caretX(left).toStringAsFixed(0)}'
          '  ${caretX(left) < caretX(5) ? "moved LEFT  OK" : "moved RIGHT  *** WRONG ***"}');
      debugPrint('   arrowRight -> offset $right x=${caretX(right).toStringAsFixed(0)}'
          '  ${caretX(right) > caretX(5) ? "moved RIGHT OK" : "moved LEFT   *** WRONG ***"}');

      if (withFix) {
        expect(caretX(left), lessThan(caretX(5)), reason: 'left arrow must go left');
        expect(caretX(right), greaterThan(caretX(5)), reason: 'right arrow must go right');
      }
    }
  });

  testWidgets('backspace removes the character to the caret\'s visual right',
      (tester) async {
    final c = TextEditingController(text: dbBody);
    final f = FocusNode();
    await tester.pumpWidget(appEditor(c, f));
    f.requestFocus();
    await tester.pump();
    for (final off in [3, 6, 11, 39]) {
      c.value = TextEditingValue(
          text: dbBody, selection: TextSelection.collapsed(offset: off));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(c.text, dbBody.replaceRange(off - 1, off, ''),
          reason: 'backspace at $off must delete exactly index ${off - 1}');
      expect(c.selection.extentOffset, off - 1);
    }
    debugPrint('backspace deletes the logically-previous char at every offset: OK');
  });
}
