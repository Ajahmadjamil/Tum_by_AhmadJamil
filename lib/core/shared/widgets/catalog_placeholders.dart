import '../../../features/poetry/models.dart';

abstract final class CatalogPlaceholders {
  static List<CategoryRow> get categories => const [
        CategoryRow(
          id: 'p-all',
          slug: 'ghazal',
          nameUrdu: 'غزل',
          nameEnglish: 'Ghazal',
        ),
        CategoryRow(
          id: 'p-nazm',
          slug: 'nazm',
          nameUrdu: 'نظم',
          nameEnglish: 'Nazm',
        ),
        CategoryRow(
          id: 'p-shair',
          slug: 'shair',
          nameUrdu: 'شعر',
          nameEnglish: 'Shair',
        ),
        CategoryRow(
          id: 'p-qataa',
          slug: 'qataa',
          nameUrdu: 'قطعہ',
          nameEnglish: 'Qataa',
        ),
      ];

  static List<PoetryCatalogRow> poems({int count = 6}) {
    return List.generate(count, PoetryCatalogRow.placeholder);
  }
}
