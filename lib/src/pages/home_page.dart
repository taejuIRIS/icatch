import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/camera_list_tab.dart';
import '../components/camera_monitor_view.dart';
import '../components/joystick_control.dart';
import '../../services/api_service.dart';
import '../components/live_time_widget.dart';

class HomePage extends StatefulWidget {
  final int? cameraId;
  final int? deviceId;
  final String? deviceIP;

  const HomePage({super.key, this.cameraId, this.deviceId, this.deviceIP});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // 바텀바 인덱스
  bool isCameraConnected = false;
  List<Map<String, dynamic>> _cameraList = [];
  int? selectedCameraId;
  String? selectedDeviceIP;

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

      if (cameras.isNotEmpty) {
        setState(() {
          _cameraList = cameras;
          selectedCameraId = widget.cameraId ?? cameras[0]['cameraId'];
          selectedDeviceIP =
              widget.deviceIP ?? 'http://ceprj.gachon.ac.kr:60004';
          isCameraConnected = true;
        });
      }
    } else {
      print(result['message']);
    }
  }

  void _registerDevice() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('카메라를 추가해 주세요!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: 기기 등록 로직
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
                        color: Color(0xFF7A5FFF),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              LiveTimeWidget(),
            ],
          ),
          Column(
            children: const [
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

  // 화면별 위젯 리스트
  List<Widget> get _pages => [
    _buildCameraPage(), // 0번 탭: 홈
    const Center(child: Text('캘린더 페이지')),
    const Center(child: Text('추가 페이지')),
    const Center(child: Text('알림 페이지')),
    const Center(child: Text('프로필 페이지')),
  ];

  Widget _buildCameraPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        CameraListTab(
          cameraList: _cameraList,
          onCameraSelected: (camera) {
            setState(() {
              selectedCameraId = camera['cameraId'];
              selectedDeviceIP = 'http://ceprj.gachon.ac.kr:60004';
            });
          },
          onAddPressed: _registerDevice,
        ),
        if (isCameraConnected && selectedDeviceIP != null)
          CameraMonitorView(deviceIP: selectedDeviceIP!)
        else
          Container(width: double.infinity, height: 220, color: Colors.black),
        const SizedBox(height: 12),
        if (isCameraConnected && selectedCameraId != null)
          JoystickControl(cameraId: selectedCameraId!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7A5FFF),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: '추가',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: '알림',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}
