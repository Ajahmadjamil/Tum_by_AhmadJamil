enum DietaryPreference {
  noPreference,
  halal,
  vegetarian,
  vegan;

  String get label {
    switch (this) {
      case DietaryPreference.noPreference:
        return 'No Preference';
      case DietaryPreference.halal:
        return 'Halal';
      case DietaryPreference.vegetarian:
        return 'Vegetarian';
      case DietaryPreference.vegan:
        return 'Vegan';
    }
  }

  /// API `dietaryPreference` value: any | halal | vegetarian | vegan
  String get apiValue {
    switch (this) {
      case DietaryPreference.noPreference:
        return 'any';
      case DietaryPreference.halal:
        return 'halal';
      case DietaryPreference.vegetarian:
        return 'vegetarian';
      case DietaryPreference.vegan:
        return 'vegan';
    }
  }
}

enum Mood {
  comfort,
  spicy,
  light,
  quick,
  special,
  kids,
  healthy,
  indulgent;

  String get label {
    switch (this) {
      case Mood.comfort:
        return 'Comfort';
      case Mood.spicy:
        return 'Spicy';
      case Mood.light:
        return 'Light';
      case Mood.quick:
        return 'Quick';
      case Mood.special:
        return 'Special';
      case Mood.kids:
        return 'Kids';
      case Mood.healthy:
        return 'Healthy';
      case Mood.indulgent:
        return 'Indulgent';
    }
  }

  /// Best-effort match from a cook-chat / API mood sentence.
  static Mood fromApiValue(String value) {
    final normalized = value.trim().toLowerCase();
    for (final mood in Mood.values) {
      if (mood.apiValue.toLowerCase() == normalized ||
          mood.label.toLowerCase() == normalized ||
          mood.name == normalized) {
        return mood;
      }
    }
    if (normalized.contains('spic')) return Mood.spicy;
    if (normalized.contains('quick') || normalized.contains('fast')) {
      return Mood.quick;
    }
    if (normalized.contains('kid') || normalized.contains('mild')) {
      return Mood.kids;
    }
    if (normalized.contains('light') || normalized.contains('healthy')) {
      return Mood.healthy;
    }
    if (normalized.contains('special') || normalized.contains('impressive')) {
      return Mood.special;
    }
    return Mood.comfort;
  }

  /// Mood string sent to the suggest API (matches web presets where possible).
  String get apiValue {
    switch (this) {
      case Mood.comfort:
        return 'Warm, cozy and satisfying home-style food';
      case Mood.spicy:
        return 'Bold Pakistani spices and noticeably spicy';
      case Mood.light:
        return 'Fresh, simple and not too heavy';
      case Mood.quick:
        return 'As quick as possible with minimal steps';
      case Mood.special:
        return 'An impressive dish worth the extra effort';
      case Mood.kids:
        return 'Mild, family-friendly and kid-approved';
      case Mood.healthy:
        return 'Fresh, simple and not too heavy';
      case Mood.indulgent:
        return 'An impressive dish worth the extra effort';
    }
  }
}

enum Difficulty {
  easy,
  medium,
  hard;

  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  static Difficulty fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return Difficulty.values.firstWhere(
      (e) => e.label.toLowerCase() == normalized || e.name == normalized,
      orElse: () => Difficulty.medium,
    );
  }
}

enum IngredientCategory {
  proteins,
  vegetables,
  grains,
  dairy,
  spices;

  String get label {
    switch (this) {
      case IngredientCategory.proteins:
        return 'Proteins';
      case IngredientCategory.vegetables:
        return 'Vegetables';
      case IngredientCategory.grains:
        return 'Grains';
      case IngredientCategory.dairy:
        return 'Dairy';
      case IngredientCategory.spices:
        return 'Spices';
    }
  }

  static IngredientCategory? fromApiLabel(String value) {
    final normalized = value.trim().toLowerCase();
    for (final category in IngredientCategory.values) {
      if (category.label.toLowerCase() == normalized ||
          category.name == normalized) {
        return category;
      }
    }
    return null;
  }
}
