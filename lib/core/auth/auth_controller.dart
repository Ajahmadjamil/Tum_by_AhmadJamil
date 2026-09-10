import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/app_supabase.dart';
import 'editor_access.dart';
import 'google_auth_config.dart';
import 'user_profile.dart';

class AuthController extends ChangeNotifier {
  AuthController();

  StreamSubscription<AuthState>? _authSub;
  User? _user;
  UserProfile? _profile;
  bool _busy = false;
  bool _googleReady = false;

  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get isSignedIn => _user != null;
  bool get isBusy => _busy;
  String? get userId => _user?.id;

  EditorAccess get editorAccess =>
      _profile?.editorAccess ?? EditorAccess.none;

  bool get isSuperadmin => editorAccess.isSuperadmin;
  bool get hasEditPermission => editorAccess.hasEditPermission;
  bool get isCatalogPublic => _profile?.isPublic ?? false;

  bool canEditPoet(String? poetId) => editorAccess.canEditPoet(poetId);

  bool canEditBook({required String poetId}) =>
      editorAccess.canEditBook(poetId: poetId);

  Future<void> load() async {
    if (!AppSupabase.isConfigured) return;
    final client = AppSupabase.client;
    _user = client.auth.currentUser;
    if (_user != null) {
      await _hydrateProfile(_user!);
    }
    await _authSub?.cancel();
    _authSub = client.auth.onAuthStateChange.listen((data) async {
      _user = data.session?.user;
      if (_user != null) {
        await _hydrateProfile(_user!);
      } else {
        _profile = null;
      }
      notifyListeners();
    });
    if (_isMobileNative && GoogleAuthConfig.hasNativeClientId) {
      try {
        await _ensureGoogleInitialized();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    if (!AppSupabase.isConfigured) {
      throw const AuthException('Supabase is not configured.');
    }
    if (!_isMobileNative) {
      throw const AuthException(
        'Google Sign-In is available on the Android and iOS apps.',
      );
    }
    if (!GoogleAuthConfig.hasNativeClientId) {
      throw const AuthException(
        'Add a Google Web client ID in google_auth_config.dart to use in-app sign-in.',
      );
    }

    _setBusy(true);
    try {
      await _nativeGoogleSignIn();
      await _syncSession();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return;
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> signOut() async {
    _setBusy(true);
    try {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
      if (AppSupabase.isConfigured) {
        await AppSupabase.client.auth.signOut();
      }
      _user = null;
      _profile = null;
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _nativeGoogleSignIn() async {
    await _ensureGoogleInitialized();
    final googleUser = await GoogleSignIn.instance.authenticate(
      scopeHint: const ['email', 'profile', 'openid'],
    );
    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw const AuthException('No ID Token found.');
    }

    String? accessToken;
    try {
      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(const ['email', 'profile']);
      accessToken = authorization?.accessToken;
    } catch (_) {}

    await AppSupabase.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleReady) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: GoogleAuthConfig.webClientId,
      clientId: GoogleAuthConfig.iosClientId.isEmpty
          ? null
          : GoogleAuthConfig.iosClientId,
    );
    _googleReady = true;
  }

  Future<void> _syncSession() async {
    _user = AppSupabase.client.auth.currentUser;
    if (_user != null) {
      await _hydrateProfile(_user!);
    } else {
      _profile = null;
    }
    notifyListeners();
  }

  Future<void> _hydrateProfile(User user) async {
    final fallback = _profileFromUser(user);
    _profile = fallback;
    try {
      try {
        await AppSupabase.client.rpc(
          'sync_own_profile',
          params: {
            'p_display_name': fallback.displayName,
            'p_avatar_url': fallback.avatarUrl,
          },
        );
      } catch (error) {
        debugPrint('Profile name sync failed: $error');
      }

      final row = await AppSupabase.client
          .from('profiles')
          .select(
            'id, display_name, avatar_url, is_superadmin, can_edit, poet_id, is_public',
          )
          .eq('id', user.id)
          .maybeSingle();
      if (row != null) {
        _profile = UserProfile.fromRow(row, email: user.email);
      }
    } catch (error) {
      debugPrint('Failed to load editor permissions: $error');
      _profile = fallback;
    }
  }

  UserProfile _profileFromUser(User user) {
    final meta = user.userMetadata ?? const <String, dynamic>{};
    return UserProfile(
      id: user.id,
      email: user.email,
      displayName: _asString(meta['full_name']) ??
          _asString(meta['name']) ??
          user.email?.split('@').first,
      avatarUrl: _asString(meta['avatar_url']) ?? _asString(meta['picture']),
    );
  }

  String? _asString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  bool get _isMobileNative =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
