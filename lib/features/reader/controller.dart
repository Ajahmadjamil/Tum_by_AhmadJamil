import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/local_db/session_store.dart';
import '../poetry/models.dart';

enum BodyAlign { left, center, right, justify }

enum ReaderFontSize { small, medium, large }

extension BodyAlignX on BodyAlign {
  String get storageKey => name;

  TextAlign get textAlign => switch (this) {
        BodyAlign.left => TextAlign.left,
        BodyAlign.center => TextAlign.center,
        BodyAlign.right => TextAlign.right,
        BodyAlign.justify => TextAlign.justify,
      };

  IconData get icon => switch (this) {
        BodyAlign.left => Icons.format_align_left,
        BodyAlign.center => Icons.format_align_center,
        BodyAlign.right => Icons.format_align_right,
        BodyAlign.justify => Icons.format_align_justify,
      };

  static BodyAlign fromStorage(String value) {
    return BodyAlign.values.firstWhere(
      (item) => item.name == value,
      orElse: () => BodyAlign.center,
    );
  }
}

extension ReaderFontSizeX on ReaderFontSize {
  String get storageKey => name;

  String get label => switch (this) {
        ReaderFontSize.small => 'S',
        ReaderFontSize.medium => 'M',
        ReaderFontSize.large => 'L',
      };

  double get fontSize => switch (this) {
        ReaderFontSize.small => 18,
        ReaderFontSize.medium => 22,
        ReaderFontSize.large => 28,
      };

  double get lineHeight => switch (this) {
        ReaderFontSize.small => 2.05,
        ReaderFontSize.medium => 2.3,
        ReaderFontSize.large => 2.45,
      };

  static ReaderFontSize fromStorage(String value) {
    return ReaderFontSize.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ReaderFontSize.medium,
    );
  }
}

class ReaderController extends ChangeNotifier {
  ReaderController({
    required List<PoetryCatalogRow> poems,
    required int initialIndex,
    this.composeCategoryId,
    SessionStore? store,
  })  : poems = List<PoetryCatalogRow>.from(poems),
        index = poems.isEmpty
            ? 0
            : initialIndex.clamp(0, poems.length - 1),
        _store = store ?? SessionStore() {
    _restore();
  }

  final SessionStore _store;
  final List<PoetryCatalogRow> poems;
  String? composeCategoryId;

  int index;
  BodyAlign align = BodyAlign.center;
  ReaderFontSize fontSize = ReaderFontSize.medium;

  bool get isComposing => composeCategoryId != null;

  PoetryCatalogRow? get current =>
      poems.isEmpty ? null : poems[index.clamp(0, poems.length - 1)];

  void replaceCurrent(PoetryCatalogRow poem) {
    if (poems.isEmpty) {
      poems.add(poem);
      index = 0;
    } else {
      poems[index] = poem;
    }
    composeCategoryId = null;
    notifyListeners();
  }

  String get body => current?.body.trim() ?? '';

  bool get hasPrevious => index > 0;
  bool get hasNext => index < poems.length - 1;
  double get progress => poems.length <= 1 ? 1 : index / (poems.length - 1);

  Future<void> _restore() async {
    align = BodyAlignX.fromStorage(await _store.readReaderAlign());
    fontSize = ReaderFontSizeX.fromStorage(await _store.readReaderFontSize());
    notifyListeners();
  }

  void goTo(int nextIndex) {
    if (poems.isEmpty) return;
    index = nextIndex.clamp(0, poems.length - 1);
    notifyListeners();
  }

  void next() => goTo(index + 1);
  void previous() => goTo(index - 1);

  Future<void> setAlign(BodyAlign next) async {
    if (align == next) return;
    align = next;
    notifyListeners();
    await _store.saveReaderAlign(next.storageKey);
  }

  Future<void> setFontSize(ReaderFontSize next) async {
    if (fontSize == next) return;
    fontSize = next;
    notifyListeners();
    await _store.saveReaderFontSize(next.storageKey);
  }

  String formattedText({required String poet, required String book}) {
    return '${body.trim()}\n\n— $poet، $book';
  }

  Future<void> copy({required String poet, required String book}) async {
    await Clipboard.setData(
      ClipboardData(text: formattedText(poet: poet, book: book)),
    );
  }

  Future<void> share({required String poet, required String book}) async {
    await SharePlus.instance.share(
      ShareParams(text: formattedText(poet: poet, book: book)),
    );
  }
}
