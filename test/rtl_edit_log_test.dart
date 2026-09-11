import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tum/core/theme/app_text_styles.dart';
import 'package:tum/features/reader/rtl_edit_log.dart';

const dbBody =
    '\u0632\u0646\u062f\u0627\u0646 \u06cc\u0648\u0633\u0641 \u0646\u06c1 \u0633\u06c1\u06cc \u0648\u0642\u062a \u06a9\u06cc \u062f\u0633\u062a\u0631\u0633 \u0645\u06cc\u06ba \u06c1\u06d2';

void main() {
  testWidgets('logger emits a readable trace', (tester) async {
    rtlEditLogging = true;
    final c = LoggingTextEditingController(label: 'BODY', text: dbBody);
    final f = FocusNode();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 320,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: RtlEditLogger(
                label: 'BODY',
                controller: c,
                child: TextField(
                  controller: c,
                  focusNode: f,
                  maxLines: null,
                  textAlign: TextAlign.start,
                  textDirection: TextDirection.rtl,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: AppTextStyles.urduEditor(fontSize: 22, height: 1.85),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    f.requestFocus();
    await tester.pump();

    await tester.tapAt(tester.getTopLeft(find.byType(TextField)) + const Offset(300, 14));
    await tester.pump(const Duration(milliseconds: 400));

    c.value = TextEditingValue(text: dbBody, selection: const TextSelection.collapsed(offset: 6));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    await tester.pump();
  });
}
