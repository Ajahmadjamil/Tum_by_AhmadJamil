// import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../constants/app_constants.dart';
//
// @pragma('vm:entry-point')
// class FirebaseNotificationService {
//   static final FirebaseMessaging _firebaseMessaging =
//       FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();
//
//   static Future<void> initialize() async {
//     await _initFirebase();
//
//     if (Platform.isAndroid) {
//       final status = await Permission.notification.status;
//       if (!status.isGranted) {
//         await Permission.notification.request();
//       }
//     }
//
//     await _initLocalNotifications();
//     await _requestPermission();
//     await _getDeviceToken();
//
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//     FirebaseMessaging.onMessage.listen(_onMessageReceived);
//     FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);
//   }
//
//   static Future<void> _initFirebase() async {
//     if (Firebase.apps.isEmpty) {
//       await Firebase.initializeApp(
//         options: DefaultFirebaseOptions.currentPlatform,
//       );
//     } else {
//       Firebase.app();
//     }
//   }
//
//   static Future<void> _initLocalNotifications() async {
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iOSInit = DarwinInitializationSettings();
//
//     const initSettings = InitializationSettings(
//       android: androidInit,
//       iOS: iOSInit,
//     );
//
//     await _localNotifications.initialize(settings: initSettings);
//
//     const androidChannel = AndroidNotificationChannel(
//       'important_channel_v2',
//       'High Importance Notifications (Custom Sound)',
//       description: 'Used for important notifications with custom sound.',
//       importance: Importance.max,
//       playSound: true,
//       sound: RawResourceAndroidNotificationSound('music'),
//     );
//
//     final androidPlugin =
//         _localNotifications.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();
//
//     await androidPlugin?.createNotificationChannel(androidChannel);
//   }
//
//   static Future<void> _requestPermission() async {
//     final settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     if (kDebugMode) {
//       print('🔔 Notification permission: ${settings.authorizationStatus}');
//     }
//
//     await _firebaseMessaging.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }
//
//   static Future<void> _getDeviceToken() async {
//     try {
//       final token = await _firebaseMessaging.getToken();
//       AppConstants.deviceToken = token ?? '123';
//       if (kDebugMode) print('✅ Device FCM Token: $token');
//     } catch (e) {
//       AppConstants.deviceToken = '123';
//       if (kDebugMode) print('❌ Error getting token: $e');
//     }
//   }
//
//   static Future<void> _onMessageReceived(RemoteMessage message) async {
//     if (kDebugMode) {
//       print('📩 Foreground message received: ${message.data}');
//     }
//
//     try {
//       if (message.notification != null) {
//         await _showLocalNotification(
//           message.notification!.title,
//           message.notification!.body,
//         );
//       }
//     } catch (e) {
//       if (kDebugMode) print('❌ Error updating rider status: $e');
//     }
//   }
//
//   static Future<void> _onMessageOpened(RemoteMessage message) async {
//     try {
//       if (kDebugMode) {
//         print('📨 Notification opened: ${message.data}');
//       }
//     } catch (e) {
//       if (kDebugMode) print('❌ Error updating rider status: $e');
//     }
//   }
//
//   static Future<void> _showLocalNotification(
//       String? title, String? body) async {
//     const androidDetails = AndroidNotificationDetails(
//       'important_channel_v2',
//       'High Importance Notifications (Custom Sound)',
//       channelDescription: 'Used for important notifications with custom sound.',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       sound: RawResourceAndroidNotificationSound('music'),
//       enableVibration: true,
//       styleInformation: BigTextStyleInformation(''),
//     );
//
//     const iosDetails = DarwinNotificationDetails(sound: 'music.mp3');
//
//     const notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     await _localNotifications.show(
//       id: DateTime.now().millisecond,
//       title: title,
//       body: body,
//       notificationDetails: notificationDetails,
//     );
//   }
//
//   @pragma('vm:entry-point') // ✅ keep function accessible to native code
//   static Future<void> _firebaseMessagingBackgroundHandler(
//       RemoteMessage message) async {
//     await Firebase.initializeApp();
//
//     final title = message.data['title'] ?? 'Notification';
//     final body = message.data['body'] ?? '';
//
//     const details = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'important_channel_v2',
//         'High Importance Notifications (Custom Sound)',
//         importance: Importance.max,
//         priority: Priority.high,
//         playSound: true,
//         sound: RawResourceAndroidNotificationSound('music'),
//       ),
//       iOS: DarwinNotificationDetails(sound: 'music.mp3'),
//     );
//
//     await _localNotifications.show(
//       id: DateTime.now().millisecond,
//       title: title,
//       body: body,
//       notificationDetails: details,
//     );
//   }
// }
