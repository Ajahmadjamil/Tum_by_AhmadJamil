import 'editor_access.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.editorAccess = EditorAccess.none,
    this.isPublic = false,
  });

  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final EditorAccess editorAccess;

  /// Dashboard flag. When true, this user's books and poetry are in the public catalog.
  final bool isPublic;

  String get visibleName {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final mail = email?.trim();
    if (mail != null && mail.isNotEmpty) return mail.split('@').first;
    return '';
  }

  factory UserProfile.fromRow(Map<String, dynamic> row, {String? email}) {
    return UserProfile(
      id: row['id'] as String,
      email: email,
      displayName: row['display_name'] as String?,
      avatarUrl: row['avatar_url'] as String?,
      editorAccess: EditorAccess.fromRow(row),
      isPublic: row['is_public'] == true || row['is_public'] == 1,
    );
  }
}
