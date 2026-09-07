// import 'dart:io' show Platform;
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
//
// import '../constants/app_constants.dart';
//
// /// Result of a store version check.
// @immutable
// class AppUpdateStatus {
//   const AppUpdateStatus({
//     required this.updateRequired,
//     this.storeVersion = '',
//     this.storeUrl = '',
//     this.immediateAllowed = false,
//   });
//
//   const AppUpdateStatus.upToDate() : this(updateRequired: false);
//
//   /// `true` when a newer build exists on the store.
//   final bool updateRequired;
//
//   /// Human-readable store version (iOS only — Android exposes a version code).
//   final String storeVersion;
//
//   /// Deep link to the store listing.
//   final String storeUrl;
//
//   /// Android only: Play can run its own full-screen blocking update in-app.
//   final bool immediateAllowed;
// }
//
// /// Store version check backing the non-dismissible update gate.
// ///
// /// Android → Play In-App Update API. This only reports for builds installed
// /// from Play, so debug / sideloaded builds always resolve to "up to date".
// /// iOS → iTunes lookup compared against the local bundle version.
// abstract final class AppUpdateService {
//   static String get playStoreUrl =>
//       'https://play.google.com/store/apps/details'
//       '?id=${AppConstants.androidPackageName}';
//
//   /// Never throws — a failed check must not block app launch.
//   static Future<AppUpdateStatus> check() async {
//     try {
//       if (Platform.isAndroid) return await _checkAndroid();
//       if (Platform.isIOS) return await _checkIOS();
//     } catch (e) {
//       debugPrint('UPDATE CHECK failed: $e');
//     }
//     return const AppUpdateStatus.upToDate();
//   }
//
//   static Future<AppUpdateStatus> _checkAndroid() async {
//     final info = await InAppUpdateManager().checkForUpdate();
//     // null → not a Play install (debug / sideload); Play has nothing to say.
//     if (info == null) return const AppUpdateStatus.upToDate();
//     if (info.updateAvailability != UpdateAvailability.updateAvailable) {
//       return const AppUpdateStatus.upToDate();
//     }
//     return AppUpdateStatus(
//       updateRequired: true,
//       storeUrl: playStoreUrl,
//       immediateAllowed: info.immediateAllowed,
//     );
//   }
//
//   static Future<AppUpdateStatus> _checkIOS() async {
//     final packageInfo = await PackageManager.getPackageInfo();
//     var versionInfo = await UpgradeVersion.getiOSStoreVersion(
//       packageInfo: packageInfo,
//       regionCode: AppConstants.appStoreRegion,
//     );
//     // The region lookup returns nothing if the app isn't in that storefront —
//     // retry against the default store before deciding.
//     if (versionInfo.storeVersion.isEmpty) {
//       versionInfo = await UpgradeVersion.getiOSStoreVersion(
//         packageInfo: packageInfo,
//       );
//     }
//     if (!versionInfo.canUpdate) return const AppUpdateStatus.upToDate();
//     return AppUpdateStatus(
//       updateRequired: true,
//       storeVersion: versionInfo.storeVersion,
//       storeUrl: versionInfo.appStoreLink,
//     );
//   }
//
//   /// Android only. Runs Play's own full-screen immediate update flow.
//   /// Returns `null` on success, or a message when it could not run —
//   /// including when the user backed out of it.
//   static Future<String?> startImmediateUpdate() {
//     return InAppUpdateManager().startAnUpdate(type: AppUpdateType.immediate);
//   }
// }
