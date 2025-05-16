import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

bool _isPollingStarted = false;

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings();
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

Future<void> showNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'default_channel_id',
    '기본 채널',
    channelDescription: 'iCatch 알림 채널',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
    largeIcon: DrawableResourceAndroidBitmap('camera_baby'),
    styleInformation: BigTextStyleInformation('확인하러 가볼까요?'),
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(subtitle: '확인하러 가볼까요?'),
  );

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    platformDetails,
  );
}

// ✅ 주기적 감시 타이머 시작 함수
void startNotificationPolling() {
  if (_isPollingStarted) return;
  _isPollingStarted = true;

  Timer.periodic(const Duration(seconds: 3), (timer) async {
    final prefs = await SharedPreferences.getInstance();
    final pushEnabled = prefs.getBool('pushToggle') ?? true;
    if (!pushEnabled) return;

    final result = await ApiService.fetchNotifications();
    final lastTime = await _getLastCheckedTime();

    final newNotifications =
        lastTime == null
            ? []
            : result.where((n) {
              final created = DateTime.tryParse(n['createdAt'] ?? '');
              return created != null && created.isAfter(lastTime);
            }).toList();

    for (var n in newNotifications) {
      await showNotification(n['title'] ?? '새 알림', '카메라 ID: ${n['cameraId']}');
    }

    if (result.isNotEmpty) {
      final newest = DateTime.tryParse(result.first['createdAt'] ?? '');
      if (newest != null) {
        await _setLastCheckedTime(newest);
      }
    }
  });
}

Future<DateTime?> _getLastCheckedTime() async {
  final prefs = await SharedPreferences.getInstance();
  final timeStr = prefs.getString('lastNotificationCheck');
  return timeStr != null ? DateTime.tryParse(timeStr) : null;
}

Future<void> _setLastCheckedTime(DateTime time) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('lastNotificationCheck', time.toIso8601String());
}
