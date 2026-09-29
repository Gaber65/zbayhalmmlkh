import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // name
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  static const AndroidNotificationChannel adminOrderChannel = AndroidNotificationChannel(
    'admin_orders_channel', // id
    'طلبات الأدمن الفورية (Admin Orders)', // name
    description: 'قناة تنبيهات الطلبات الجديدة وتحديثاتها لإدارة المتجر',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  // Broadcast stream for in-app live order alerts
  final StreamController<Map<String, dynamic>> _adminOrderAlertController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get adminOrderAlertStream =>
      _adminOrderAlertController.stream;

  void emitAdminOrderAlert(Map<String, dynamic> data) {
    if (!_adminOrderAlertController.isClosed) {
      _adminOrderAlertController.add(data);
    }
  }

  Future<void> init() async {
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle foreground notification tap here
        print('Notification clicked with payload: ${response.payload}');
      },
    );

    // Create standard & admin channels on the device
    final androidImpl = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.createNotificationChannel(channel);
    await androidImpl?.createNotificationChannel(adminOrderChannel);

    // Update iOS foreground notification presentation options
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Subscribe admin device to order notifications
  Future<void> subscribeToAdminTopics() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('admin_orders');
      await FirebaseMessaging.instance.subscribeToTopic('orders');
      await FirebaseMessaging.instance.subscribeToTopic('all');
      print('Subscribed to admin order notification topics successfully.');
    } catch (e) {
      print('Error subscribing to admin topics: $e');
    }
  }

  Future<String?> _downloadAndSaveFile(String url, String fileName) async {
    try {
      final Directory tempDir = Directory.systemTemp;
      final String filePath = '${tempDir.path}/$fileName';
      final response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final File file = File(filePath);
      await file.writeAsBytes(response.data);
      return filePath;
    } catch (e) {
      print('Error downloading image for notification: $e');
      return null;
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // Check if this message is an admin order alert
    final bool isAdminOrder = message.data['type'] == 'new_order' ||
        message.data['type'] == 'order_status' ||
        message.from?.contains('admin_orders') == true;

    if (isAdminOrder) {
      emitAdminOrderAlert({
        'title': notification?.title ?? 'طلب جديد وارد! 🥩',
        'body': notification?.body ?? 'وصل طلب جديد في انتظار المراجعة والتجهيز.',
        'order_id': message.data['order_id'],
        'data': message.data,
      });
    }

    if (notification != null && android != null) {
      String? bigPicturePath;
      BigPictureStyleInformation? bigPictureStyleInformation;

      // Extract image URL from either FCM payload or data
      String? imageUrl = android.imageUrl ?? message.data['image'];

      if (imageUrl != null && imageUrl.isNotEmpty) {
        bigPicturePath = await _downloadAndSaveFile(imageUrl, 'bigPicture.jpg');
        if (bigPicturePath != null) {
          bigPictureStyleInformation = BigPictureStyleInformation(
            FilePathAndroidBitmap(bigPicturePath),
            hideExpandedLargeIcon: true,
            contentTitle: notification.title,
            summaryText: notification.body,
          );
        }
      }

      // Parse actions from data payload if available
      List<AndroidNotificationAction>? actions;
      if (message.data.containsKey('action')) {
        actions = [
          AndroidNotificationAction(
            message.data['action'] as String,
            'View',
            showsUserInterface: true,
          ),
        ];
      }

      final currentChannel = isAdminOrder ? adminOrderChannel : channel;

      flutterLocalNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            currentChannel.id,
            currentChannel.name,
            channelDescription: currentChannel.description,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFFE2211C), // Dhabayih Lmamlaka Brand Red
            styleInformation: bigPictureStyleInformation,
            actions: actions,
            importance: currentChannel.importance,
            priority: Priority.max,
            enableVibration: true,
            playSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Manually trigger a simulated local admin order notification for testing / instant feedback
  Future<void> triggerSimulatedAdminOrder({
    String orderNumber = 'ORD-2026-9999',
    double total = 1850.0,
    String customerName = 'عميل جديد (تجريبي)',
    String? title,
    String? body,
  }) async {
    final effectiveTitle = title ?? '🔔 طلب جديد وارد: $orderNumber';
    final effectiveBody =
        body ?? 'قام العميل ($customerName) بطلب جديد بقيمة $total ر.س';

    emitAdminOrderAlert({
      'title': effectiveTitle,
      'body': effectiveBody,
      'order_number': orderNumber,
      'total': total,
      'customer_name': customerName,
    });

    flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: effectiveTitle,
      body: effectiveBody,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          adminOrderChannel.id,
          adminOrderChannel.name,
          channelDescription: adminOrderChannel.description,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFC59A3F), // Royal Gold
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        ),
      ),
    );
  }
}

