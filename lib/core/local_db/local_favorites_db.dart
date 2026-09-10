import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// Device-local favorites. Guest hearts stay here; signed-in users get a
/// per-account cache that can sync to Supabase when online.
class LocalFavoritesDb {
  static const guestOwner = 'guest';
  static const _prefsFavoritesKey = 'favorite_poetry_ids';

  Database? _db;

  Future<Database> get _database async {
    final existing = _db;
    if (existing != null) return existing;
    final dir = await getDatabasesPath();
    final opened = await openDatabase(
      p.join(dir, 'tum_local.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE favorites (
            owner_id TEXT NOT NULL,
            poetry_id TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            PRIMARY KEY (owner_id, poetry_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE sync_meta (
            owner_id TEXT PRIMARY KEY,
            dirty INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
    _db = opened;
    await _migrateSharedPreferences();
    return opened;
  }

  Future<void> _migrateSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getStringList(_prefsFavoritesKey);
    if (legacy == null || legacy.isEmpty) return;
    await replaceAll(guestOwner, legacy);
    await prefs.remove(_prefsFavoritesKey);
  }

  Future<Set<String>> readIds(String ownerId) async {
    final rows = await (await _database).query(
      'favorites',
      columns: const ['poetry_id'],
      where: 'owner_id = ?',
      whereArgs: [ownerId],
    );
    return rows.map((row) => row['poetry_id']! as String).toSet();
  }

  Future<void> setFavorite({
    required String ownerId,
    required String poetryId,
    required bool favorite,
  }) async {
    final db = await _database;
    if (favorite) {
      await db.insert(
        'favorites',
        {
          'owner_id': ownerId,
          'poetry_id': poetryId,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } else {
      await db.delete(
        'favorites',
        where: 'owner_id = ? AND poetry_id = ?',
        whereArgs: [ownerId, poetryId],
      );
    }
    await setDirty(ownerId, true);
  }

  Future<void> replaceAll(String ownerId, Iterable<String> ids) async {
    final db = await _database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      await txn.delete(
        'favorites',
        where: 'owner_id = ?',
        whereArgs: [ownerId],
      );
      for (final id in ids) {
        await txn.insert('favorites', {
          'owner_id': ownerId,
          'poetry_id': id,
          'created_at': now,
        });
      }
    });
  }

  Future<bool> isDirty(String ownerId) async {
    final rows = await (await _database).query(
      'sync_meta',
      columns: const ['dirty'],
      where: 'owner_id = ?',
      whereArgs: [ownerId],
    );
    if (rows.isEmpty) return false;
    return (rows.first['dirty'] as int? ?? 0) != 0;
  }

  Future<void> setDirty(String ownerId, bool dirty) async {
    await (await _database).insert(
      'sync_meta',
      {'owner_id': ownerId, 'dirty': dirty ? 1 : 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
