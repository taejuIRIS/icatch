import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app.dart'; // 실제 MyApp 정의된 곳
import 'utils/notification_util.dart'; // ✅ 직접 만든 유틸리티 임포트

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin(); // 전역 선언

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('ko_KR', null);

  // 🔔 알림 초기화
  await initializeNotifications(); // ✅ 유틸리티 함수로 알림 초기화

  // 🔁 알림 감시 타이머 시작
  startNotificationPolling(); // ✅ 앱 실행 중 언제든 알림 뜨게 함

  runApp(const MyApp());
}
