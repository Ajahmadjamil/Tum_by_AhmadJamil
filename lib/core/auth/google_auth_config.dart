/// In-app Google Sign-In (account picker, not Chrome).
///
/// Use a **Web application** OAuth client ID from Google Cloud
/// (APIs & Services → Credentials). A Desktop/installed client will not work.
///
/// Also create an **Android** OAuth client:
///   package: com.ahmadjamil.tum
///   SHA-1: your debug/release keystore fingerprint
///
/// Paste the same Web client ID + secret in
/// Supabase → Authentication → Providers → Google.
abstract final class GoogleAuthConfig {
  static const webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '1070651645721-k91rsu41ec9j1fjdgp0ipr53fp55llqq.apps.googleusercontent.com',
  );

  static const iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '',
  );

  static bool get hasNativeClientId => webClientId.trim().isNotEmpty;
}
