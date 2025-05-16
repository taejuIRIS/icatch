import 'package:flutter/material.dart';
import 'camera_list_tab.dart';
import 'camera_monitor_view.dart';
import 'joystick_control.dart'; // ✅ 추가

class CameraMonitorScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cameraList;
  final Map<String, dynamic>? initialSelectedCamera;
  final void Function(Map<String, dynamic>)? onCameraChanged;

  const CameraMonitorScreen({
    super.key,
    required this.cameraList,
    this.initialSelectedCamera,
    this.onCameraChanged,
  });

  @override
  State<CameraMonitorScreen> createState() => _CameraMonitorScreenState();
}

class _CameraMonitorScreenState extends State<CameraMonitorScreen> {
  Map<String, dynamic>? _selectedCamera;

  @override
  void initState() {
    super.initState();
    // 초기 선택 카메라 설정
    _selectedCamera =
        widget.initialSelectedCamera ??
        (widget.cameraList.isNotEmpty ? widget.cameraList.first : null);
  }

  void _onCameraSelected(Map<String, dynamic> camera) {
    setState(() {
      _selectedCamera = camera;
    });

    if (widget.onCameraChanged != null) {
      widget.onCameraChanged!(camera);
    }

    debugPrint("💡 선택된 카메라: ${camera['deviceIp']}");
  }

  void _onAddCameraPressed() {
    debugPrint("➕ 카메라 추가 버튼 클릭됨");
  }

  @override
  Widget build(BuildContext context) {
    final hasCamera =
        _selectedCamera != null &&
        _selectedCamera!['deviceIp'] != null &&
        _selectedCamera!['deviceIp'].toString().trim().isNotEmpty;

    return Column(
      children: [
        // 📷 카메라 리스트 탭
        CameraListTab(
          cameraList: widget.cameraList,
          selectedCameraId: _selectedCamera?['cameraId'],
          onCameraSelected: _onCameraSelected,
          onAddPressed: _onAddCameraPressed,
        ),

        const SizedBox(height: 10),

        // 🔴 MJPEG WebView
        if (hasCamera)
          CameraMonitorView(deviceIP: _selectedCamera!['deviceIp'])
        else
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('표시할 카메라가 없습니다', style: TextStyle(fontSize: 16)),
          ),

        const SizedBox(height: 16),

        // 🕹️ 조이스틱
        if (hasCamera) JoystickControl(deviceIP: _selectedCamera!['deviceIp']),
      ],
    );
  }
}
