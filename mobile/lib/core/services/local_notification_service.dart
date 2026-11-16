import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class LocalNotificationService extends GetxService {
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationDetails(
    'app_notifications',
    'Notifications',
    channelDescription: 'Order, quotation and message updates',
    importance: Importance.max, // heads-up banner at the top
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );

  Future<LocalNotificationService> init() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/importlogo'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (_) =>
          Get.toNamed(AppRoutes.notifications),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return this;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) {
    return _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: _channel,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
    );
  }
}