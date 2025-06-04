import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../components/camera_list_tab.dart';
import '../components/joystick_control.dart';
import '../components/live_time_widget.dart';
import '../components/camera_monitor_view.dart';
import '../../services/api_service.dart';
import '../navbar/bottom_navbar.dart';
import 'add_page.dart';
import 'notification_page.dart';
import 'personal_page.dart';

final logger = Logger();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _selectedIndex = 0;
  List<Map<String, dynamic>> _cameraList = [];
  Map<String, dynamic>? _selectedCamera;

  bool _isNewlyAdded = false;

  @override
  void initState() {
    super.initState();
    _loadCameraList();
  }

  Future<void> _loadCameraList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return;

    final result = await ApiService.fetchUserCameras(token);
    if (result['success']) {
      final cameras = List<Map<String, dynamic>>.from(result['data']);
      final validCameras =
          cameras
              .where(
                (camera) =>
                    camera['cameraName'] != null &&
                    camera['deviceIp'] != null &&
                    camera['deviceIp'].toString().trim().isNotEmpty,
              )
              .toList();

      setState(() {
        _cameraList = validCameras;
        if (_selectedCamera == null && validCameras.isNotEmpty) {
          _selectedCamera = validCameras.first;
          _storeCameraInfo(_selectedCamera!);
        }
      });
    } else {
      logger.e('카메라 목록 불러오기 실패: ${result['message']}');
      setState(() {
        _cameraList = [];
        _selectedCamera = null;
      });
    }
  }

  void _storeCameraInfo(Map<String, dynamic> camera) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cameraId', camera['cameraId']);
    await prefs.setInt('deviceId', camera['deviceId']);
    await prefs.setString('deviceIP', camera['deviceIp']);
  }

  void _registerDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인 정보가 없습니다.')));
      return;
    }

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('카메라를 추가해 주세요!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(
                    context,
                    '/DeviceQRPage',
                    arguments: {'userId': userId},
                  );
                },
                child: const Text(
                  '기기 등록',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'i',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'Catch',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A4DFF),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              LiveTimeWidget(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const Divider(color: Color(0xFFE0E0E0), thickness: 1, height: 1),
        const SizedBox(height: 10),
        CameraListTab(
          cameraList: _cameraList,
          selectedCameraId: _selectedCamera?['cameraId'],
          onCameraSelected: (camera) async {
            setState(() {
              _selectedCamera = camera;
              _isNewlyAdded = false;
            });
            logger.i(
              '📷 선택된 카메라 변경됨 => cameraId: ${camera['cameraId']}, deviceId: ${camera['deviceId']}, IP: ${camera['deviceIp']}',
            );
            _storeCameraInfo(camera);
          },
          onAddPressed: _registerDevice,
          isNewlyAdded: _isNewlyAdded,
        ),
        const SizedBox(height: 10),
        if (_selectedCamera != null && _selectedCamera!['deviceIp'] != null)
          CameraMonitorView(
            key: ValueKey(_selectedCamera!['cameraId']),
            deviceIP: _selectedCamera!['deviceIp'],
          ),
        const SizedBox(height: 5),
        if (_selectedCamera != null &&
            _selectedCamera!['cameraId'] != null &&
            _selectedCamera!['deviceIp'] != null)
          JoystickControl(deviceIP: _selectedCamera!['deviceIp']),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _buildCameraPage()),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex) return;

          Widget nextPage;
          switch (index) {
            case 0:
              nextPage = const HomePage();
              break;
            case 1:
              nextPage = const AddPage();
              break;
            case 2:
              nextPage = const NotificationPage();
              break;
            case 3:
              nextPage = const PersonalPage();
              break;
            default:
              return;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => nextPage),
          );
        },
      ),
    );
  }
}
