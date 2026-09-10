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

  Map<String, dynamic> toMap() => {
        'id': id,
        'slug': slug,
        'name_urdu': nameUrdu,
        'name_english': nameEnglish,
      };
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'slug': slug,
        'name_urdu': nameUrdu,
        'name_english': nameEnglish,
        'avatar_url': avatarUrl,
      };
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'poet_id': poetId,
        'slug': slug,
        'title_urdu': titleUrdu,
        'title_english': titleEnglish,
        'cover_image_url': coverImageUrl,
        'release_year': releaseYear,
        'poets': {
          'name_urdu': poetNameUrdu,
          'name_english': poetNameEnglish,
        },
      };
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

  String? get firstBodyLine {
    final teaser = teaserLine1?.trim();
    if (teaser != null && teaser.isNotEmpty) return teaser;
    for (final line in body.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

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

  Map<String, dynamic> toMap() => {
        'id': id,
        'slug': slug,
        'title_urdu': titleUrdu,
        'title_english': titleEnglish,
        'category_slug': categorySlug,
        'category_name_urdu': categoryNameUrdu,
        'category_name_english': categoryNameEnglish,
        'poet_id': poetId,
        'poet_name_urdu': poetNameUrdu,
        'poet_name_english': poetNameEnglish,
        'book_id': bookId,
        'book_title_urdu': bookTitleUrdu,
        'book_title_english': bookTitleEnglish,
        'sort_order': sortOrder,
        'body': body,
        'teaser_line_1': teaserLine1,
        'teaser_line_2': teaserLine2,
      };

  factory PoetryCatalogRow.placeholder(int index) {
    return PoetryCatalogRow(
      id: 'placeholder-$index',
      slug: 'placeholder-$index',
      titleUrdu: 'عنوان کلام',
      titleEnglish: null,
      categorySlug: 'ghazal',
      categoryNameUrdu: 'غزل',
      categoryNameEnglish: 'Ghazal',
      poetId: 'placeholder-poet',
      poetNameUrdu: 'احمد جمیل',
      poetNameEnglish: 'Ahmad Jamil',
      bookId: 'placeholder-book',
      bookTitleUrdu: 'تم',
      bookTitleEnglish: 'Tum',
      sortOrder: index,
      body: 'یہ پہلی سطر ہے',
      teaserLine1: 'یہ پہلی سطر ہے',
      teaserLine2: null,
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'image_url': imageUrl,
        'teaser_line_1': teaserLine1,
        'teaser_line_2': teaserLine2,
        'poetry_id': poetryId,
        'title_urdu': titleUrdu,
        'poet_name_urdu': poetNameUrdu,
        'poet_name_english': poetNameEnglish,
        'book_title_urdu': bookTitleUrdu,
        'book_title_english': bookTitleEnglish,
      };

  factory BannerRow.placeholder() {
    return const BannerRow(
      id: 'placeholder-banner',
      title: 'تم',
      imageUrl: null,
      teaserLine1: 'پہلی سطرِ شعر',
      teaserLine2: 'دوسری سطرِ شعر',
      poetryId: null,
      titleUrdu: 'تم',
      poetNameUrdu: 'احمد جمیل',
      poetNameEnglish: 'Ahmad Jamil',
      bookTitleUrdu: 'تم',
      bookTitleEnglish: 'Tum',
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

  Map<String, dynamic> toMap() => {
        'display_date': displayDate,
        'teaser_line_1': teaserLine1,
        'teaser_line_2': teaserLine2,
        'poet_name_urdu': poetNameUrdu,
        'poet_name_english': poetNameEnglish,
        'book_title_urdu': bookTitleUrdu,
        'book_title_english': bookTitleEnglish,
        'poetry_id': poetryId,
      };

  factory QuoteRow.placeholder() {
    return const QuoteRow(
      displayDate: '2026-01-01',
      teaserLine1: 'آج کا شعر یہاں آئے گا',
      teaserLine2: 'دوسری سطر یہاں آئے گی',
      poetNameUrdu: 'احمد جمیل',
      poetNameEnglish: 'Ahmad Jamil',
      bookTitleUrdu: 'تم',
      bookTitleEnglish: 'Tum',
      poetryId: 'placeholder-quote',
    );
  }
}
