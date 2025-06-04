import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'device_camname.dart';
import '../../components/camera_monitor_view.dart'; // 경로는 실제 위치에 맞게 수정

class DeviceCheckQRPage extends StatefulWidget {
  final int cameraId;
  final int deviceId;
  final String deviceIP;

  const DeviceCheckQRPage({
    super.key,
    required this.cameraId,
    required this.deviceId,
    required this.deviceIP,
  });

  @override
  State<DeviceCheckQRPage> createState() => _DeviceCheckQRPageState();
}

class _DeviceCheckQRPageState extends State<DeviceCheckQRPage> {
  Future<void> _goToNextStep() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSetup', true);

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => DeviceCamNamePage(
              deviceId: widget.deviceId,
              deviceIP: widget.deviceIP,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
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
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 2 / 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A4DFF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '잘하셨습니다!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF090A0A),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '화면이 잘 보이는 지 확인해 주세요!',
                    style: TextStyle(fontSize: 16, color: Color(0xFF090A0A)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ✅ 영상 표시 영역 - 재사용 컴포넌트
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.black,
                  child: CameraMonitorView(
                    // deviceIP: '${widget.deviceIP}', // ✅ ngrok는 반드시 https
                    deviceIP: '${widget.deviceIP}',
                  ),
                ),
              ),
            ),

            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _goToNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
