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
  bool isCameraConnected = false;
  List<Map<String, dynamic>> _cameraList = [];
  int? selectedCameraId;
  int? selectedDeviceId;
  String? selectedDeviceIP;

  @override
  void initState() {
    super.initState();
    _loadCameraList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
          cameras.where((camera) {
            final name = camera['cameraName'];
            final ip = camera['deviceIp'];
            return name != null &&
                ip != null &&
                ip.toString().trim().isNotEmpty;
          }).toList();

      setState(() {
        _cameraList = validCameras;
        if (validCameras.isNotEmpty && selectedCameraId == null) {
          final first = validCameras.first;
          selectedCameraId = first['cameraId'];
          selectedDeviceId = first['deviceId'];
          selectedDeviceIP = first['deviceIp'];
          isCameraConnected = true;

          logger.i(
            '📡 초기 선택된 카메라: IP=${first['deviceIp']}, ID=${first['cameraId']}, Device=${first['deviceId']}',
          );

          // ✅ 저장
          prefs.setInt('cameraId', selectedCameraId!);
          prefs.setInt('deviceId', selectedDeviceId!);
          prefs.setString('deviceIP', selectedDeviceIP!);
        }
      });
    } else {
      logger.e('카메라 목록 불러오기 실패: ${result['message']}');
      setState(() {
        _cameraList = [];
        isCameraConnected = false;
      });
    }
  }

  void _registerDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인 정보가 없습니다.')));
      return;
    }

    showDialog(
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
          const Column(
            children: [
              Icon(Icons.water_drop, color: Colors.black),
              SizedBox(height: 4),
              Text(
                '24°C/40%',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
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
        CameraListTab(
          cameraList: _cameraList,
          selectedCameraId: selectedCameraId,
          onCameraSelected: (camera) async {
            final prefs = await SharedPreferences.getInstance();
            setState(() {
              selectedCameraId = camera['cameraId'];
              selectedDeviceId = camera['deviceId'];
              selectedDeviceIP = camera['deviceIp'];
              isCameraConnected = true;
            });

            logger.i(
              '📷 선택된 카메라 변경됨 => cameraId: $selectedCameraId, deviceId: $selectedDeviceId, IP: $selectedDeviceIP',
            );

            prefs.setInt('cameraId', selectedCameraId!);
            prefs.setInt('deviceId', selectedDeviceId!);
            prefs.setString('deviceIP', selectedDeviceIP!);
          },
          onAddPressed: _registerDevice,
        ),
        const SizedBox(height: 12),
        if (isCameraConnected && selectedDeviceIP != null)
          CameraMonitorView(deviceIP: selectedDeviceIP!),
        const SizedBox(height: 16),
        if (isCameraConnected && selectedCameraId != null)
          JoystickControl(cameraId: selectedCameraId!),
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
