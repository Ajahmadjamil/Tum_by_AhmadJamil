// import 'dart:io' show Platform;
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../analytics/app_analytics.dart';
// import '../constants/app_constants.dart';
// import '../theme/app_colors.dart';
// import 'update_service.dart';
//
// /// Full-screen, non-dismissible update gate shown straight after the splash.
// ///
// /// There is deliberately no "later" affordance: [PopScope] swallows the back
// /// gesture and Update is the only action. The gate closes itself only when a
// /// re-check on resume confirms the app is current, so the user cannot reach
// /// the app on a stale build.
// class ForceUpdateScreen extends StatefulWidget {
//   const ForceUpdateScreen({super.key, required this.status});
//
//   final AppUpdateStatus status;
//
//   @override
//   State<ForceUpdateScreen> createState() => _ForceUpdateScreenState();
// }
//
// class _ForceUpdateScreenState extends State<ForceUpdateScreen>
//     with WidgetsBindingObserver {
//   bool _busy = false;
//   String? _error;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     AppAnalytics.screen(AnalyticsScreen.forceUpdate);
//
//     // Play can host the whole blocking flow itself, so start it unprompted —
//     // that makes the common Android path genuinely automatic.
//     if (Platform.isAndroid && widget.status.immediateAllowed) {
//       WidgetsBinding.instance.addPostFrameCallback((_) => _update());
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // Back from the store — let them through only if they actually updated.
//     if (state == AppLifecycleState.resumed) _recheck();
//   }
//
//   Future<void> _recheck() async {
//     final status = await AppUpdateService.check();
//     if (!mounted || status.updateRequired) return;
//     Navigator.of(context).pop();
//   }
//
//   Future<void> _update() async {
//     if (_busy) return;
//     setState(() {
//       _busy = true;
//       _error = null;
//     });
//
//     try {
//       if (Platform.isAndroid && widget.status.immediateAllowed) {
//         final failure = await AppUpdateService.startImmediateUpdate();
//         // Non-null means Play's flow never ran, or the user backed out of it.
//         if (failure == null) return;
//       }
//       await _openStore();
//     } finally {
//       if (mounted) setState(() => _busy = false);
//     }
//   }
//
//   Future<void> _openStore() async {
//     final url = widget.status.storeUrl;
//     if (url.isEmpty) {
//       _fail('Store link unavailable. Please update from the store manually.');
//       return;
//     }
//     try {
//       final launched = await launchUrl(
//         Uri.parse(url),
//         mode: LaunchMode.externalApplication,
//       );
//       if (!launched) _fail('Could not open the store.');
//     } catch (_) {
//       _fail('Could not open the store.');
//     }
//   }
//
//   void _fail(String message) {
//     if (mounted) setState(() => _error = message);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final version = widget.status.storeVersion;
//
//     return PopScope(
//       canPop: false,
//       child: Scaffold(
//         backgroundColor: AppColors.canvas,
//         body: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 104,
//                     height: 104,
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: AppColors.ctaGradient,
//                     ),
//                     child: const Icon(
//                       Icons.rocket_launch_rounded,
//                       size: 48,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   Text(
//                     'Time to update',
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.outfit(
//                       fontSize: 26,
//                       fontWeight: FontWeight.w800,
//                       color: AppColors.text,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     'A newer version of ${AppConstants.appName} is available. '
//                     'Update to keep cooking.',
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.outfit(
//                       fontSize: 15,
//                       height: 1.5,
//                       fontWeight: FontWeight.w400,
//                       color: AppColors.textMuted,
//                     ),
//                   ),
//                   if (version.isNotEmpty) ...[
//                     const SizedBox(height: 16),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.tipBg,
//                         borderRadius: BorderRadius.circular(999),
//                         border: Border.all(color: AppColors.tipBorder),
//                       ),
//                       child: Text(
//                         'Version $version',
//                         style: GoogleFonts.outfit(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.primaryDark,
//                         ),
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 36),
//                   _UpdateButton(busy: _busy, onPressed: _update),
//                   if (_error != null) ...[
//                     const SizedBox(height: 16),
//                     Text(
//                       _error!,
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.outfit(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.error,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _UpdateButton extends StatelessWidget {
//   const _UpdateButton({required this.busy, required this.onPressed});
//
//   final bool busy;
//   final VoidCallback onPressed;
//
//   @override
//   Widget build(BuildContext context) {
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         gradient: AppColors.ctaGradient,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withValues(alpha: 0.28),
//             blurRadius: 18,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16),
//           onTap: busy ? null : onPressed,
//           child: SizedBox(
//             width: double.infinity,
//             height: 54,
//             child: Center(
//               child: busy
//                   ? const SizedBox(
//                       width: 22,
//                       height: 22,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2.4,
//                         color: Colors.white,
//                       ),
//                     )
//                   : Text(
//                       'Update Now',
//                       style: GoogleFonts.outfit(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
