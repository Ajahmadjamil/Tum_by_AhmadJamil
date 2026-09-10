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
  String get starPoetry => urdu ? 'مشہور میں شامل کریں' : 'Add to Popular';
  String get unstarPoetry => urdu ? 'مشہور سے ہٹائیں' : 'Remove from Popular';
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
  String get superadminAccessGranted => urdu
      ? 'آپ کے پاس پوری ایپ میں ترمیم کی اجازت ہے'
      : 'You can edit everything in the app';
  String get poetEditorAccessGranted => urdu
      ? 'آپ اپنے کلام اور کتاب میں ترمیم کر سکتے ہیں'
      : 'You can edit your books and poetry';
  String get superadminBadge => urdu ? 'سپر ایڈمن' : 'Superadmin';
  String get editorBadge => urdu ? 'ترمیم کی اجازت' : 'Editor access';
  String get catalogPublicBadge =>
      urdu ? 'سب دیکھ سکتے ہیں' : 'Visible to everyone';
  String get catalogHiddenBadge =>
      urdu ? 'کیٹلاگ میں پوشیدہ' : 'Hidden from catalog';
  String get addPoetry => urdu ? 'نیا کلام' : 'New poem';
  String get poetryTitleHint => urdu ? 'عنوان' : 'Title';
  String get poetryBodyHint => urdu ? 'کلام یہاں لکھیں' : 'Write the poem here';
  String get publishPoetry => urdu ? 'شائع کریں' : 'Publish';
  String get poetryPublished => urdu ? 'کلام شامل ہو گیا' : 'Poem added';
  String get poetryPublishFailed =>
      urdu ? 'کلام شامل نہیں ہو سکا' : 'Could not add the poem';
  String get selectBook => urdu ? 'کتاب' : 'Book';
  String get selectCategory => urdu ? 'زمرہ' : 'Category';
  String get pickCategoryFirst =>
      urdu ? 'پہلے ایک زمرہ چنیں' : 'Pick a category first';
  String get poetrySaving => urdu ? 'محفوظ ہو رہا ہے' : 'Saving';
  String get poetrySaved => urdu ? 'محفوظ ہو گیا' : 'Saved';
  String get savePoetry => urdu ? 'محفوظ کریں' : 'Save';
  String get discardChanges => urdu ? 'نظرانداز' : 'Discard';
  String get unsavedTitle => urdu ? 'تبدیلیاں محفوظ کریں؟' : 'Save changes?';
  String get unsavedBody => urdu
      ? 'کلام میں تبدیلی ہے جو ابھی محفوظ نہیں ہوئی۔'
      : 'You have unsaved changes to this poem.';
  String get deletePoetry => urdu ? 'حذف کریں' : 'Delete';
  String get deletePoetryTitle => urdu ? 'کلام حذف کریں؟' : 'Delete this poem?';
  String get deletePoetryBody => urdu
      ? 'یہ کلام ردی میں چلا جائے گا۔ آپ اسے پروفائل سے بحال کر سکتے ہیں۔'
      : 'This poem will move to Trash. You can restore it from Profile.';
  String get poetryMovedToTrash => urdu ? 'کلام ردی میں چلا گیا' : 'Moved to Trash';
  String get trash => urdu ? 'ردی' : 'Trash';
  String get emptyTrash => urdu ? 'ردی خالی کریں' : 'Empty trash';
  String get emptyTrashTitle => urdu ? 'ردی خالی کریں؟' : 'Empty trash?';
  String get emptyTrashBody => urdu
      ? 'ردی کے تمام کلام مستقل طور پر مٹ جائیں گے اور واپس نہیں آ سکتے۔'
      : 'Everything in Trash will be permanently deleted and cannot be restored.';
  String get restorePoetry => urdu ? 'بحال کریں' : 'Restore';
  String get deleteForever => urdu ? 'مستقل حذف' : 'Delete forever';
  String get deleteForeverTitle =>
      urdu ? 'مستقل طور پر حذف کریں؟' : 'Delete forever?';
  String get deleteForeverBody => urdu
      ? 'یہ کلام مستقل طور پر مٹ جائے گا اور واپس نہیں آ سکتا۔'
      : 'This poem will be permanently deleted and cannot be restored.';
  String get emptyTrashList => urdu ? 'ردی خالی ہے' : 'Trash is empty';
  String get poetryRestored => urdu ? 'کلام بحال ہو گیا' : 'Poem restored';
  String get poetryPurged => urdu ? 'کلام مستقل حذف ہو گیا' : 'Poem permanently deleted';

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
