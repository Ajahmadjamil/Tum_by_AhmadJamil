import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// RTL caret + backspace for Urdu.
///
/// Tapping into existing text often leaves a downstream caret. The IME then
/// deletes the visual-left letter once; after that it behaves. This controller
/// rewrites that first delete to the visual-right letter and keeps the caret
/// upstream.
class RtlTextEditingController extends TextEditingController {
  RtlTextEditingController({super.text});

  bool _correcting = false;
  bool _scheduled = false;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  set value(TextEditingValue newValue) {
    if (_correcting) {
      super.value = newValue;
      return;
    }

    final previous = super.value;
    var next = newValue;

    if (_isWrongRtlBackspace(previous, next)) {
      next = _deleteToTheRight(previous);
    } else if (_shouldPreferUpstream(previous, next)) {
      next = next.copyWith(
        selection: TextSelection.collapsed(
          offset: next.selection.extentOffset.clamp(0, next.text.length),
          affinity: TextAffinity.upstream,
        ),
      );
    }

    _correcting = true;
    super.value = next;
    _correcting = false;
    _scheduleUpstream();
  }

  /// IME deleted the character after the caret (visual left in RTL).
  bool _isWrongRtlBackspace(TextEditingValue old, TextEditingValue next) {
    if (old.composing.isValid || next.composing.isValid) return false;
    if (!old.selection.isValid || !old.selection.isCollapsed) return false;
    if (!next.selection.isCollapsed) return false;
    if (next.text.length >= old.text.length) return false;

    final offset = old.selection.extentOffset;
    if (offset < 0 || offset > old.text.length) return false;
    if (next.selection.extentOffset != offset) return false;
    if (offset > next.text.length) return false;
    if (!next.text.startsWith(old.text.substring(0, offset))) return false;

    final oldAfter = old.text.substring(offset);
    final nextAfter = next.text.substring(offset);
    if (!oldAfter.endsWith(nextAfter)) return false;

    final deleted = oldAfter.substring(0, oldAfter.length - nextAfter.length);
    return deleted.isNotEmpty;
  }

  TextEditingValue _deleteToTheRight(TextEditingValue old) {
    final offset = old.selection.extentOffset;
    if (offset <= 0) {
      return old.copyWith(
        selection: const TextSelection.collapsed(offset: 0, affinity: TextAffinity.upstream),
      );
    }
    final start = CharacterBoundary(old.text).getLeadingTextBoundaryAt(offset - 1) ?? 0;
    return TextEditingValue(
      text: old.text.replaceRange(start, offset, ''),
      selection: TextSelection.collapsed(offset: start, affinity: TextAffinity.upstream),
    );
  }

  bool _shouldPreferUpstream(TextEditingValue old, TextEditingValue next) {
    if (next.composing.isValid) return false;
    if (!next.selection.isValid || !next.selection.isCollapsed) return false;
    if (next.selection.affinity == TextAffinity.upstream) return false;
    return old.text == next.text;
  }

  void _scheduleUpstream() {
    if (_scheduled || _disposed) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (_disposed) return;
      final current = super.value;
      if (current.composing.isValid) return;
      if (!current.selection.isValid || !current.selection.isCollapsed) return;
      if (current.selection.affinity == TextAffinity.upstream) return;
      _correcting = true;
      super.value = current.copyWith(
        selection: TextSelection.collapsed(
          offset: current.selection.extentOffset.clamp(0, current.text.length),
          affinity: TextAffinity.upstream,
        ),
      );
      _correcting = false;
    });
  }
}
