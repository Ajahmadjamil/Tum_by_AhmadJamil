import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../features/poetry/models.dart';

class CatalogSnapshot {
  const CatalogSnapshot({
    required this.categories,
    required this.poets,
    required this.books,
    required this.catalog,
    required this.banners,
    required this.quote,
  });

  final List<CategoryRow> categories;
  final List<PoetRow> poets;
  final List<BookRow> books;
  final List<PoetryCatalogRow> catalog;
  final List<BannerRow> banners;
  final QuoteRow? quote;

  bool get isEmpty => catalog.isEmpty && categories.isEmpty;

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((item) => item.toMap()).toList(),
      'poets': poets.map((item) => item.toMap()).toList(),
      'books': books.map((item) => item.toMap()).toList(),
      'catalog': catalog.map((item) => item.toMap()).toList(),
      'banners': banners.map((item) => item.toMap()).toList(),
      'quote': quote?.toMap(),
    };
  }

  factory CatalogSnapshot.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String key) {
      final raw = json[key];
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    QuoteRow? quote;
    final quoteJson = json['quote'];
    if (quoteJson is Map) {
      quote = QuoteRow.fromMap(Map<String, dynamic>.from(quoteJson));
    }

    return CatalogSnapshot(
      categories: list('categories').map(CategoryRow.fromMap).toList(),
      poets: list('poets').map(PoetRow.fromMap).toList(),
      books: list('books').map(BookRow.fromMap).toList(),
      catalog: list('catalog').map(PoetryCatalogRow.fromMap).toList(),
      banners: list('banners').map(BannerRow.fromMap).toList(),
      quote: quote,
    );
  }
}

/// Disk cache for catalog, gallery, categories, banners, and today's verse.
class AppDataCache {
  static const _snapshotKey = 'catalog_snapshot_v1';

  Database? _db;

  Future<Database> get _database async {
    final existing = _db;
    if (existing != null) return existing;
    final dir = await getDatabasesPath();
    final opened = await openDatabase(
      p.join(dir, 'tum_app_cache.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE kv_cache (
            cache_key TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
    );
    _db = opened;
    return opened;
  }

  Future<CatalogSnapshot?> readSnapshot() async {
    try {
      final rows = await (await _database).query(
        'kv_cache',
        columns: const ['payload'],
        where: 'cache_key = ?',
        whereArgs: const [_snapshotKey],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final payload = rows.first['payload'] as String?;
      if (payload == null || payload.isEmpty) return null;
      final json = await compute(decodeCachePayload, payload);
      return CatalogSnapshot.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSnapshot(CatalogSnapshot snapshot) async {
    try {
      final payload = await compute(encodeCachePayload, snapshot.toJson());
      await (await _database).insert(
        'kv_cache',
        {
          'cache_key': _snapshotKey,
          'payload': payload,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }
}

Map<String, dynamic> decodeCachePayload(String payload) {
  return Map<String, dynamic>.from(jsonDecode(payload) as Map);
}

String encodeCachePayload(Map<String, dynamic> json) => jsonEncode(json);
