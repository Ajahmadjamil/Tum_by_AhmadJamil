import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/local_db/local_favorites_db.dart';
import 'remote_favorites.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController({
    required AuthController auth,
    LocalFavoritesDb? db,
    RemoteFavoritesRepository? remote,
  })  : _auth = auth,
        _db = db ?? LocalFavoritesDb(),
        _remote = remote ?? RemoteFavoritesRepository();

  final AuthController _auth;
  final LocalFavoritesDb _db;
  final RemoteFavoritesRepository _remote;
  final Set<String> _ids = {};
  String _ownerId = LocalFavoritesDb.guestOwner;
  bool _listening = false;
  bool hydrating = false;

  Set<String> get ids => _ids;

  bool isFavorite(String poetryId) => _ids.contains(poetryId);

  Future<void> load() async {
    _ownerId = _auth.userId ?? LocalFavoritesDb.guestOwner;
    _ids
      ..clear()
      ..addAll(await _db.readIds(_ownerId));
    if (_auth.userId != null) {
      _ids.addAll(await _db.readIds(LocalFavoritesDb.guestOwner));
    }
    notifyListeners();
    if (!_listening) {
      _listening = true;
      _auth.addListener(_onAuthChanged);
    }
    unawaited(_syncSignedIn());
  }

  Future<void> toggle(String poetryId) async {
    final favorite = !_ids.contains(poetryId);
    if (favorite) {
      _ids.add(poetryId);
    } else {
      _ids.remove(poetryId);
    }
    notifyListeners();

    await _db.setFavorite(
      ownerId: _ownerId,
      poetryId: poetryId,
      favorite: favorite,
    );

    final userId = _auth.userId;
    if (userId == null) return;
    try {
      await _remote.setFavorite(
        userId: userId,
        poetryId: poetryId,
        favorite: favorite,
      );
    } catch (_) {}
  }

  Future<void> _onAuthChanged() async {
    final nextOwner = _auth.userId ?? LocalFavoritesDb.guestOwner;
    if (nextOwner == _ownerId) return;

    final previous = _ownerId;
    if (previous != LocalFavoritesDb.guestOwner &&
        nextOwner == LocalFavoritesDb.guestOwner) {
      await _db.replaceAll(LocalFavoritesDb.guestOwner, _ids);
      _ownerId = nextOwner;
      _ids
        ..clear()
        ..addAll(await _db.readIds(LocalFavoritesDb.guestOwner));
      notifyListeners();
      return;
    }

    _ownerId = nextOwner;
    final guest = await _db.readIds(LocalFavoritesDb.guestOwner);
    final local = await _db.readIds(nextOwner);
    _ids
      ..clear()
      ..addAll({...guest, ...local});
    await _db.replaceAll(nextOwner, _ids);
    notifyListeners();
    unawaited(_syncSignedIn());
  }

  Future<void> _syncSignedIn() async {
    final userId = _auth.userId;
    if (userId == null) return;

    hydrating = _ids.isEmpty;
    if (hydrating) notifyListeners();

    final local = {..._ids};
    for (final poetryId in local) {
      try {
        await _remote.setFavorite(
          userId: userId,
          poetryId: poetryId,
          favorite: true,
        );
      } catch (_) {}
    }

    try {
      final remote = await _remote.fetch(userId);
      final merged = {...local, ...remote};
      _ids
        ..clear()
        ..addAll(merged);
      await _db.replaceAll(userId, merged);
      notifyListeners();
    } catch (_) {}

    hydrating = false;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_listening) {
      _auth.removeListener(_onAuthChanged);
    }
    super.dispose();
  }
}
