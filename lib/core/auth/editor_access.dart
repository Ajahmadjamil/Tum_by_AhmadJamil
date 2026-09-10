/// Editor rights stored on `profiles` in Supabase.
///
/// Set these in the dashboard — the app only reads them:
///   is_superadmin = true  → can edit everything
///   can_edit = true + poet_id → can edit that poet's books / poetry
class EditorAccess {
  const EditorAccess({
    this.isSuperadmin = false,
    this.canEdit = false,
    this.poetId,
  });

  static const none = EditorAccess();

  final bool isSuperadmin;
  final bool canEdit;
  final String? poetId;

  bool get _ownsAPoet {
    final id = poetId;
    return canEdit && id != null && id.isNotEmpty;
  }

  /// True when this login should see editor UI / the permission toast.
  bool get hasEditPermission => isSuperadmin || _ownsAPoet;

  bool canEditPoet(String? poetId) {
    if (isSuperadmin) return true;
    if (!_ownsAPoet || poetId == null || poetId.isEmpty) return false;
    return this.poetId == poetId;
  }

  bool canEditBook({required String poetId}) => canEditPoet(poetId);

  factory EditorAccess.fromRow(Map<String, dynamic> row) {
    return EditorAccess(
      isSuperadmin: _asBool(row['is_superadmin']),
      canEdit: _asBool(row['can_edit']),
      poetId: row['poet_id'] as String?,
    );
  }

  static bool _asBool(dynamic value) {
    return value == true || value == 1 || value == 'true';
  }
}
