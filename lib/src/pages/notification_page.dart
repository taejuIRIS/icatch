import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../navbar/bottom_navbar.dart';
import '../../services/api_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> notifications = [];
  bool _pushEnabled = true;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _initializeNotifications();
    _loadPushToggle().then((_) => _loadNotifications());
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _loadPushToggle() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('pushToggle');
    _pushEnabled = saved ?? true;
  }

  Future<void> _initializeNotifications() async {
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

  Future<void> _loadNotifications() async {
    final result = await ApiService.fetchNotifications();
    final lastTime = await _getLastCheckedTime();

    final newNotifications =
        lastTime == null
            ? []
            : result.where((n) {
              final created = DateTime.tryParse(n['createdAt'] ?? '');
              return created != null && created.isAfter(lastTime);
            }).toList();

    if (_pushEnabled) {
      for (var n in newNotifications) {
        await _showNotification(
          n['title'] ?? '새 알림',
          '카메라 ID: ${n['cameraId']}',
        );
      }
    }

    if (result.isNotEmpty) {
      final newest = DateTime.tryParse(result.first['createdAt'] ?? '');
      if (newest != null) {
        await _setLastCheckedTime(newest);
      }
    }

    setState(() {
      notifications = result;
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

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
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

  String _formatTime(String iso) {
    try {
      DateTime dt = DateTime.parse(iso).toLocal();
      return DateFormat('M/d HH:mm').format(dt);
    } catch (e) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavbar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/CalendarPage');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/AddPage');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/PersonalPage');
              break;
          }
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'i',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: 'Catch',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A4DFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '알림',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child:
                    notifications.isEmpty
                        ? const Center(child: Text('알림이 없습니다.'))
                        : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final n = notifications[index];
                            return _notificationTile(
                              title: n['title'] ?? '',
                              description: '카메라 ID: ${n['cameraId']}',
                              time: _formatTime(n['createdAt']),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationTile({
    required String title,
    required String description,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/images/camera_baby.png', width: 40, height: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF090A0A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C7072),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6C7072)),
          ),
        ],
      ),
    );
  }
}
