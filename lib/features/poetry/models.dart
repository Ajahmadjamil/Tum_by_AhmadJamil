class CategoryRow {
  const CategoryRow({
    required this.id,
    required this.slug,
    required this.nameUrdu,
    required this.nameEnglish,
  });

  final String id;
  final String slug;
  final String nameUrdu;
  final String nameEnglish;

  factory CategoryRow.fromMap(Map<String, dynamic> row) {
    return CategoryRow(
      id: row['id'] as String,
      slug: row['slug'] as String,
      nameUrdu: row['name_urdu'] as String,
      nameEnglish: row['name_english'] as String,
    );
  }
}

class PoetRow {
  const PoetRow({
    required this.id,
    required this.slug,
    required this.nameUrdu,
    required this.nameEnglish,
    this.avatarUrl,
  });

  final String id;
  final String slug;
  final String nameUrdu;
  final String? nameEnglish;
  final String? avatarUrl;

  factory PoetRow.fromMap(Map<String, dynamic> row) {
    return PoetRow(
      id: row['id'] as String,
      slug: row['slug'] as String,
      nameUrdu: row['name_urdu'] as String,
      nameEnglish: row['name_english'] as String?,
      avatarUrl: row['avatar_url'] as String?,
    );
  }
}

class BookRow {
  const BookRow({
    required this.id,
    required this.poetId,
    required this.slug,
    required this.titleUrdu,
    required this.titleEnglish,
    required this.coverImageUrl,
    required this.releaseYear,
    required this.poetNameUrdu,
    required this.poetNameEnglish,
  });

  final String id;
  final String poetId;
  final String slug;
  final String titleUrdu;
  final String? titleEnglish;
  final String? coverImageUrl;
  final int? releaseYear;
  final String? poetNameUrdu;
  final String? poetNameEnglish;

  factory BookRow.fromMap(Map<String, dynamic> row) {
    final poet = row['poets'];
    Map<String, dynamic>? poetMap;
    if (poet is Map) {
      poetMap = Map<String, dynamic>.from(poet);
    }
    return BookRow(
      id: row['id'] as String,
      poetId: row['poet_id'] as String,
      slug: row['slug'] as String,
      titleUrdu: row['title_urdu'] as String,
      titleEnglish: row['title_english'] as String?,
      coverImageUrl: row['cover_image_url'] as String?,
      releaseYear: row['release_year'] as int?,
      poetNameUrdu: poetMap?['name_urdu'] as String?,
      poetNameEnglish: poetMap?['name_english'] as String?,
    );
  }
}

class PoetryCatalogRow {
  const PoetryCatalogRow({
    required this.id,
    required this.slug,
    required this.titleUrdu,
    required this.titleEnglish,
    required this.categorySlug,
    required this.categoryNameUrdu,
    required this.categoryNameEnglish,
    required this.poetId,
    required this.poetNameUrdu,
    required this.poetNameEnglish,
    required this.bookId,
    required this.bookTitleUrdu,
    required this.bookTitleEnglish,
    required this.sortOrder,
    required this.body,
    required this.teaserLine1,
    required this.teaserLine2,
  });

  final String id;
  final String slug;
  final String titleUrdu;
  final String? titleEnglish;
  final String categorySlug;
  final String categoryNameUrdu;
  final String categoryNameEnglish;
  final String poetId;
  final String poetNameUrdu;
  final String? poetNameEnglish;
  final String? bookId;
  final String? bookTitleUrdu;
  final String? bookTitleEnglish;
  final int sortOrder;
  final String body;
  final String? teaserLine1;
  final String? teaserLine2;

  factory PoetryCatalogRow.fromMap(Map<String, dynamic> row) {
    return PoetryCatalogRow(
      id: row['id'] as String,
      slug: row['slug'] as String,
      titleUrdu: row['title_urdu'] as String,
      titleEnglish: row['title_english'] as String?,
      categorySlug: row['category_slug'] as String,
      categoryNameUrdu: row['category_name_urdu'] as String? ?? '',
      categoryNameEnglish: row['category_name_english'] as String? ?? '',
      poetId: row['poet_id'] as String,
      poetNameUrdu: row['poet_name_urdu'] as String,
      poetNameEnglish: row['poet_name_english'] as String?,
      bookId: row['book_id'] as String?,
      bookTitleUrdu: row['book_title_urdu'] as String?,
      bookTitleEnglish: row['book_title_english'] as String?,
      sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
      body: row['body'] as String? ?? '',
      teaserLine1: row['teaser_line_1'] as String?,
      teaserLine2: row['teaser_line_2'] as String?,
    );
  }
}

class BannerRow {
  const BannerRow({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.teaserLine1,
    required this.teaserLine2,
    required this.poetryId,
    required this.titleUrdu,
    required this.poetNameUrdu,
    required this.poetNameEnglish,
    required this.bookTitleUrdu,
    required this.bookTitleEnglish,
  });

  final String id;
  final String? title;
  final String? imageUrl;
  final String? teaserLine1;
  final String? teaserLine2;
  final String? poetryId;
  final String? titleUrdu;
  final String? poetNameUrdu;
  final String? poetNameEnglish;
  final String? bookTitleUrdu;
  final String? bookTitleEnglish;

  factory BannerRow.fromMap(Map<String, dynamic> row) {
    return BannerRow(
      id: row['id'] as String,
      title: row['title'] as String?,
      imageUrl: row['image_url'] as String?,
      teaserLine1: row['teaser_line_1'] as String?,
      teaserLine2: row['teaser_line_2'] as String?,
      poetryId: row['poetry_id'] as String?,
      titleUrdu: row['title_urdu'] as String?,
      poetNameUrdu: row['poet_name_urdu'] as String?,
      poetNameEnglish: row['poet_name_english'] as String?,
      bookTitleUrdu: row['book_title_urdu'] as String?,
      bookTitleEnglish: row['book_title_english'] as String?,
    );
  }
}

class QuoteRow {
  const QuoteRow({
    required this.displayDate,
    required this.teaserLine1,
    required this.teaserLine2,
    required this.poetNameUrdu,
    required this.poetNameEnglish,
    required this.bookTitleUrdu,
    required this.bookTitleEnglish,
    required this.poetryId,
  });

  final String displayDate;
  final String? teaserLine1;
  final String? teaserLine2;
  final String poetNameUrdu;
  final String? poetNameEnglish;
  final String? bookTitleUrdu;
  final String? bookTitleEnglish;
  final String poetryId;

  factory QuoteRow.fromMap(Map<String, dynamic> row) {
    return QuoteRow(
      displayDate: row['display_date'].toString(),
      teaserLine1: row['teaser_line_1'] as String?,
      teaserLine2: row['teaser_line_2'] as String?,
      poetNameUrdu: row['poet_name_urdu'] as String,
      poetNameEnglish: row['poet_name_english'] as String?,
      bookTitleUrdu: row['book_title_urdu'] as String?,
      bookTitleEnglish: row['book_title_english'] as String?,
      poetryId: row['poetry_id'] as String,
    );
  }

  factory QuoteRow.fromLatest(PoetryCatalogRow poem) {
    return QuoteRow(
      displayDate: DateTime.now().toIso8601String().split('T').first,
      teaserLine1: poem.teaserLine1,
      teaserLine2: poem.teaserLine2,
      poetNameUrdu: poem.poetNameUrdu,
      poetNameEnglish: poem.poetNameEnglish,
      bookTitleUrdu: poem.bookTitleUrdu,
      bookTitleEnglish: poem.bookTitleEnglish,
      poetryId: poem.id,
    );
  }
}
