import 'package:flutter/foundation.dart';

import '../../core/local_db/session_store.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController({SessionStore? store}) : _store = store ?? SessionStore();

  final SessionStore _store;
  final Set<String> _ids = {};

  Set<String> get ids => _ids;

  bool isFavorite(String poetryId) => _ids.contains(poetryId);

  Future<void> load() async {
    _ids
      ..clear()
      ..addAll(await _store.readFavoriteIds());
    notifyListeners();
  }

  Future<void> toggle(String poetryId) async {
    if (_ids.contains(poetryId)) {
      _ids.remove(poetryId);
    } else {
      _ids.add(poetryId);
    }
    await _store.saveFavoriteIds(_ids.toList());
    notifyListeners();
  }
}
