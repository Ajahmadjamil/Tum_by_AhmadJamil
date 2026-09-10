class AppStrings {
  const AppStrings({required this.urdu});

  final bool urdu;

  String get appName => urdu ? 'تم' : 'Tum';
  String get searchHint => urdu ? 'نظم' : 'Search';
  String get home => urdu ? 'ہوم' : 'Home';
  String get favorites => urdu ? 'پسندیدہ' : 'Favorites';
  String get gallery => urdu ? 'گیلری' : 'Gallery';
  String get profile => urdu ? 'پروفائل' : 'Profile';
  String get seeMore => urdu ? 'مزید دیکھیے' : 'See more';
  String get aajKaShair => urdu ? 'آج کا شعر' : "Today's verse";
  String get language => urdu ? 'زبان' : 'Language';
  String get theme => urdu ? 'تھیم' : 'Theme';
  String get lightTheme => urdu ? 'روشن' : 'Light';
  String get darkTheme => urdu ? 'تاریک' : 'Dark';
  String get urduLabel => 'اردو';
  String get englishLabel => 'English';
  String get emptyFavorites =>
      urdu ? 'ابھی کوئی پسندیدہ شعر نہیں' : 'No favorites yet';
  String get emptyGallery =>
      urdu ? 'گیلری جلد آرہی ہے' : 'Gallery coming soon';
  String get bookLabel => urdu ? 'کتاب' : 'Book';
  String get copied => urdu ? 'کاپی ہو گیا' : 'Copied';
  String get notifications => urdu ? 'اطلاعات' : 'Notifications';
  String get englishToggle => urdu ? 'انگریزی' : 'English';
  String get allCategories => urdu ? 'تمام' : 'All';
  String get emptyCategory =>
      urdu ? 'اس زمرے میں ابھی کلام نہیں' : 'No poetry in this category yet';
  String get exitAppTitle => urdu ? 'ایپ بند کریں؟' : 'Exit app?';
  String get exitAppBody =>
      urdu ? 'کیا آپ ایپ بند کرنا چاہتے ہیں؟' : 'Do you want to close the app?';
  String get exit => urdu ? 'خروج' : 'Exit';
  String get cancel => urdu ? 'منسوخ' : 'Cancel';
  String get guestName => urdu ? 'مہمان' : 'Guest';
  String get guestHint => urdu
      ? 'ایپ بغیر سائن ان کے چلتی ہے۔ گوگل سے سائن ان کریں تو پسندیدہ آپ کے پروفائل سے جڑ جائیں گے۔'
      : 'The app works without an account. Sign in with Google to save favorites to your profile.';
  String get signedInHint => urdu
      ? 'پسندیدہ آپ کے پروفائل سے منسلک ہیں۔ آف لائن میں وہ اس فون پر محفوظ رہتے ہیں۔'
      : 'Favorites are linked to your profile, and still work offline on this device.';
  String get signInWithGoogle =>
      urdu ? 'گوگل سے سائن ان' : 'Sign in with Google';
  String get signOut => urdu ? 'سائن آؤٹ' : 'Sign out';
  String get signInFailed =>
      urdu ? 'سائن ان نہیں ہو سکا' : 'Could not sign in';
  String get signInCanceled => urdu ? 'سائن ان منسوخ ہوا' : 'Sign in canceled';

  String poemCount(int count) {
    return urdu ? '$count کلام' : '$count pieces';
  }

  String kalamOf(String poetName) {
    return urdu ? 'کلام $poetName' : 'Kalam $poetName';
  }

  String attribution({
    required String poet,
    required String book,
    required String category,
  }) {
    return urdu
        ? '($poet - $bookLabel: $book - $category)'
        : '($poet — $book — $category)';
  }
}
