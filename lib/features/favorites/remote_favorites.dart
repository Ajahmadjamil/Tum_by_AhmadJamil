import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/app_supabase.dart';

class RemoteFavoritesRepository {
  SupabaseClient get _client => AppSupabase.client;

  Future<Set<String>> fetch(String userId) async {
    final rows = await _client
        .from('user_favorites')
        .select('poetry_id')
        .eq('user_id', userId);
    return rows
        .map((row) => row['poetry_id'] as String)
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<void> setFavorite({
    required String userId,
    required String poetryId,
    required bool favorite,
  }) async {
    if (favorite) {
      await _client.from('user_favorites').upsert({
        'user_id': userId,
        'poetry_id': poetryId,
      });
      return;
    }
    await _client.from('user_favorites').delete().match({
      'user_id': userId,
      'poetry_id': poetryId,
    });
  }

  Future<void> upsertMany(String userId, Iterable<String> ids) async {
    final payload = ids
        .map((id) => {'user_id': userId, 'poetry_id': id})
        .toList();
    if (payload.isEmpty) return;
    await _client.from('user_favorites').upsert(payload);
  }

  Future<void> deleteMany(String userId, Iterable<String> ids) async {
    for (final id in ids) {
      await _client.from('user_favorites').delete().match({
        'user_id': userId,
        'poetry_id': id,
      });
    }
  }
}
