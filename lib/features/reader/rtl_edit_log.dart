import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Diagnostic instrumentation for the Urdu notes editor.
///
/// Everything here is logging only — it never changes a TextEditingValue. Flip
/// [rtlEditLogging] off (or ship a release build) to compile it out of the hot
/// path. Coordinates are reported in **left-to-right pixels**: x=0 is the
/// physical LEFT edge of the field, x=width is the physical RIGHT edge, which
/// in RTL text is where a line *starts*.
bool rtlEditLogging = kDebugMode;

/// A/B knob for the notes editor. `true` = behave like a normal Android notes
/// app (Gboard keeps a composing region over the word being edited). `false` =
/// NO_SUGGESTIONS, which makes Gboard forget Urdu word structure.
bool debugUrduSuggestions = true;

const _tag = 'RTLLOG';

void _out(String s) {
  if (!rtlEditLogging) return;
  debugPrint('$_tag $s');
}

/// Renders a string as codepoints so invisible characters cannot hide.
String cp(String s) => s.split('').map((c) {
      final u =
          'U+${c.codeUnitAt(0).toRadixString(16).toUpperCase().padLeft(4, '0')}';
      if (c == '\n') return '$u[NL]';
      if (c == ' ') return '$u[SP]';
      return '$u[$c]';
    }).join(' ');

/// Logs every value the field passes through, whoever caused it: the soft
/// keyboard, a hardware key, a tap, or our own code.
class LoggingTextEditingController extends TextEditingController {
  LoggingTextEditingController({required this.label, super.text});

  final String label;

  /// Set by [RtlEditLogger] so each change can be labelled with its trigger.
  String cause = 'init';

  @override
  set value(TextEditingValue newValue) {
    final old = super.value;
    super.value = newValue;
    if (!rtlEditLogging) return;
    final same = old.text == newValue.text &&
        old.selection == newValue.selection &&
        old.composing == newValue.composing;
    if (same) return;
    _logChange(old, newValue);
    cause = 'ime';
  }

  void _logChange(TextEditingValue a, TextEditingValue b) {
    _out('=== $label [$cause] ===');
    _out('  len ${a.text.length} -> ${b.text.length}   '
        'caret ${_sel(a.selection)} -> ${_sel(b.selection)}   '
        'composing ${_rng(a.composing)} -> ${_rng(b.composing)}');

    if (a.text != b.text) {
      final pre = _commonPrefix(a.text, b.text);
      final suf = _commonSuffix(a.text, b.text, pre);
      final removed = a.text.substring(pre, a.text.length - suf);
      final added = b.text.substring(pre, b.text.length - suf);
      if (removed.isNotEmpty) {
        _out('  REMOVED ${removed.length} at index $pre : ${cp(removed)}');
      }
      if (added.isNotEmpty) {
        _out('  INSERTED ${added.length} at index $pre : ${cp(added)}');
      }
      final caretWas = a.selection.isValid ? a.selection.extentOffset : -1;
      if (removed.isNotEmpty && added.isEmpty && caretWas >= 0) {
        final expected = caretWas - removed.length;
        final verdict = pre == expected
            ? 'OK (ate the logically-previous char)'
            : 'MISMATCH (ate the WRONG SIDE)';
        _out(
            '  backspace check: deleted at $pre, expected $expected -> $verdict');
      }
      if (b.composing.isValid) {
        final s = b.composing.start.clamp(0, b.text.length);
        final e = b.composing.end.clamp(0, b.text.length);
        _out('  IME is composing over: ${cp(b.text.substring(s, e))}'
            '   <-- keyboard owns this run and may rewrite all of it');
      }
    }
    _out('  around caret ${_around(b.text, b.selection.extentOffset)}');
  }

  String _around(String t, int off) {
    if (off < 0 || off > t.length) return '(caret out of range: $off)';
    final s = (off - 3).clamp(0, t.length);
    final e = (off + 3).clamp(0, t.length);
    return '${cp(t.substring(s, off))} >>CARET<< ${cp(t.substring(off, e))}';
  }

  static String _sel(TextSelection s) {
    if (!s.isValid) return 'invalid';
    if (s.isCollapsed) return '${s.extentOffset}(${s.affinity.name})';
    return '${s.baseOffset}..${s.extentOffset}';
  }

  static String _rng(TextRange r) => r.isValid ? '${r.start}..${r.end}' : '-';

  static int _commonPrefix(String a, String b) {
    var i = 0;
    while (i < a.length && i < b.length && a[i] == b[i]) {
      i++;
    }
    return i;
  }

  static int _commonSuffix(String a, String b, int prefix) {
    var i = 0;
    while (i < a.length - prefix &&
        i < b.length - prefix &&
        a[a.length - 1 - i] == b[b.length - 1 - i]) {
      i++;
    }
    return i;
  }
}

/// Wraps the editor to report pointer taps, raw key events, and — after each
/// frame — exactly where the caret and its neighbouring glyphs are painted.
class RtlEditLogger extends StatefulWidget {
  const RtlEditLogger({
    super.key,
    required this.label,
    required this.controller,
    required this.child,
  });

  final String label;
  final LoggingTextEditingController controller;
  final Widget child;

  @override
  State<RtlEditLogger> createState() => _RtlEditLoggerState();
}

class _RtlEditLoggerState extends State<RtlEditLogger> {
  final _fieldKey = GlobalKey();
  TextSelection? _lastLogged;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_scheduleGeometry);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scheduleGeometry);
    super.dispose();
  }

  void _scheduleGeometry() {
    if (!rtlEditLogging) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _logGeometry();
    });
  }

  RenderEditable? _renderEditable() {
    RenderEditable? hit;
    void walk(RenderObject? node) {
      if (node == null || hit != null) return;
      if (node is RenderEditable) {
        hit = node;
        return;
      }
      node.visitChildren(walk);
    }

    walk(_fieldKey.currentContext?.findRenderObject());
    return hit;
  }

  void _logGeometry() {
    final re = _renderEditable();
    final sel = widget.controller.selection;
    if (re == null || !sel.isValid || !sel.isCollapsed) return;
    if (_lastLogged == sel) return;
    _lastLogged = sel;

    final text = widget.controller.text;
    final off = sel.extentOffset;
    if (off < 0 || off > text.length) return;
    final caret = re.getLocalRectForCaret(
        TextPosition(offset: off, affinity: sel.affinity));
    final w = re.size.width;
    _out(
        '  --- geometry (x grows LEFT to RIGHT, field width ${w.toStringAsFixed(0)}) ---');
    _out('  caret at offset $off painted x=${caret.left.toStringAsFixed(1)} '
        'y=${caret.top.toStringAsFixed(1)}  '
        '[${caret.left.toStringAsFixed(0)}px from LEFT, '
        '${(w - caret.left).toStringAsFixed(0)}px from RIGHT]');

    void glyph(String tag, int start, int end) {
      if (start < 0 || end > text.length || start >= end) return;
      final boxes = re.getBoxesForSelection(
        TextSelection(baseOffset: start, extentOffset: end),
      );
      if (boxes.isEmpty) return;
      final b = boxes.first;
      final side = b.left >= caret.left ? 'RIGHT of caret' : 'LEFT of caret';
      _out('  $tag ${cp(text.substring(start, end))} '
          'x=${b.left.toStringAsFixed(1)}..${b.right.toStringAsFixed(1)} -> $side');
    }

    glyph('logical-PREV (backspace should eat this):', off - 1, off);
    glyph('logical-NEXT (forward-delete would eat this):', off, off + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) {
        if (!rtlEditLogging) return;
        final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
        if (box == null) return;
        final local = box.globalToLocal(e.position);
        widget.controller.cause = 'tap';
        _out('=== ${widget.label} [tap] ===');
        _out('  tapped x=${local.dx.toStringAsFixed(1)} '
            'y=${local.dy.toStringAsFixed(1)} '
            'field width ${box.size.width.toStringAsFixed(0)} '
            '[${local.dx.toStringAsFixed(0)}px from LEFT, '
            '${(box.size.width - local.dx).toStringAsFixed(0)}px from RIGHT]');
        _lastLogged = null;
        _scheduleGeometry();
      },
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: (_, event) {
          if (rtlEditLogging && event is KeyDownEvent) {
            widget.controller.cause = 'key:${event.logicalKey.debugName}';
            _out('=== ${widget.label} [key] ${event.logicalKey.debugName} ===');
            _lastLogged = null;
          }
          return KeyEventResult.ignored;
        },
        child: KeyedSubtree(key: _fieldKey, child: widget.child),
      ),
    );
  }
}
