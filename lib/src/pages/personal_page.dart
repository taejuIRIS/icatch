import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../navbar/bottom_navbar.dart';
import 'home_page.dart';
import 'add_page.dart';
import 'notification_page.dart';
import 'package:frontend1/src/pages/targets/targets_list.dart';
import 'package:frontend1/src/pages/devices/device_list.dart';
import 'package:frontend1/src/pages/mypage/users_setting_page.dart';
import 'package:frontend1/src/pages/album/album_list_page.dart';
import '../../services/api_service.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  final int _selectedIndex = 3;
  String usernickname = '';
  String email = '';
  bool notificationEnabled = true; // ✅ 기본값 true

  int cameraCount = 0;
  int targetCount = 0;
  int gestureCount = 0;

  @override
  void initState() {
    super.initState();
    _loadToggleSetting(); // ✅ 알림 설정 불러오기
    _fetchProfile();
    _fetchCameraCount();
    _fetchTargetCount();
    _fetchGestureCount();
  }

  // ✅ SharedPreferences에서 토글 상태 불러오기
  Future<void> _loadToggleSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('pushToggle');
    setState(() {
      notificationEnabled = saved ?? true;
    });
  }

  // ✅ SharedPreferences에만 저장 (API 호출 제거)
  Future<void> _toggleNotification(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushToggle', enabled);
    setState(() {
      notificationEnabled = enabled;
    });
  }

  Future<void> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return;

    final result = await ApiService.fetchUserProfile(token);
    if (result['success']) {
      final data = result['data'];
      setState(() {
        usernickname = data['usernickname'] ?? '';
        email = data['email'] ?? '';
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'] ?? '프로필 조회 실패')));
    }
  }

  Future<void> _fetchCameraCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return;

    final count = await ApiService.fetchCameraCount(token);
    setState(() {
      cameraCount = count;
    });
  }

  Future<void> _fetchTargetCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final userId = prefs.getInt('userId');
    if (token == null || userId == null) return;

    final count = await ApiService.fetchTargetCount(token, userId);
    setState(() {
      targetCount = count;
    });
  }

  Future<void> _fetchGestureCount() async {
    final gestures = await ApiService.fetchAllGestures();
    setState(() {
      gestureCount = gestures.length;
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AddPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NotificationPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "i",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "Catch",
                          style: TextStyle(
                            color: Color(0xFF6A4DFF),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              color: const Color(0xFF6A4DFF),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/images/baby-cat.png"),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    usernickname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 22),
              color: const Color(0xFFC6C4FF),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoCard(Icons.camera_alt, "$cameraCount 대"),
                  _buildInfoCard(Icons.pets, "$targetCount 마리(명)"),
                  _buildInfoCard(Icons.pan_tool, "$gestureCount 개"),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(Icons.notifications, "알림", true),
                  _buildMenuItem(
                    Icons.camera_alt,
                    "카메라",
                    false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeviceListPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.pets,
                    "주거인",
                    false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TargetListPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.photo_album,
                    "앨범",
                    false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AlbumListPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.settings,
                    "설정",
                    false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserSettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF673AB7), size: 32),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Color(0xFF673AB7))),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    bool isToggle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing:
          isToggle
              ? Switch(
                value: notificationEnabled,
                onChanged: (val) => _toggleNotification(val),
                activeColor: const Color(0xFF673AB7),
              )
              : const Icon(Icons.chevron_right),
      onTap: isToggle ? null : onTap,
    );
  }
}
