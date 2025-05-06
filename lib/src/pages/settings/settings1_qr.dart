import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/wifi_setup_modal.dart';
import 'settings2_checkqr.dart'; // CheckMonitoringPage import

class SettingsQRPage extends StatefulWidget {
  final int userId;

  const SettingsQRPage({super.key, required this.userId});

  @override
  State<SettingsQRPage> createState() => _SettingsQRPageState();
}

class _SettingsQRPageState extends State<SettingsQRPage> {
  String? qrData;

  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWifiModal();
    });
  }

  void _showWifiModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => WifiSetupModal(
            ssidController: _ssidController,
            passwordController: _passwordController,
            onConfirm: () {
              final wifiJson = {
                'userId': widget.userId,
                'ssid': _ssidController.text,
                'password': _passwordController.text, // 무조건 포함, 빈 문자열이라도
              };

              setState(() {
                qrData = jsonEncode(wifiJson);
              });

              Navigator.of(context).pop();
            },
          ),
    );
  }

  Future<void> _completeSetupAndGoHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSetup', true);

    final deviceInfo = await fetchDeviceInfo(widget.userId);
    print('✅ 디바이스 정보: $deviceInfo');

    if (!mounted) return;

    if (deviceInfo != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => CheckMonitoringPage(
                deviceId: deviceInfo['deviceId'],
                cameraId: deviceInfo['cameraId'],
                deviceIP: deviceInfo['deviceIP'],
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("디바이스 정보가 아직 없습니다.")));
    }
  }

  Future<Map<String, dynamic>?> fetchDeviceInfo(int userId) async {
    final url = Uri.parse(
      'http://ceprj.gachon.ac.kr:60004/api/device/auth/authenticate?userId=$userId',
    );

    try {
      final response = await http.get(url);
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      print('✅ 서버 응답: $decoded');
      print('📦 response.statusCode: ${response.statusCode}');
      print('✅ success의 타입: ${decoded['success'].runtimeType}');
      print('✅ success의 값: ${decoded['success']}');

      // ✅ 핵심 조건 수정
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded['success'] == true) {
        return decoded['data'];
      } else {
        print('❌ 서버 응답 실패 또는 success false');
        return null;
      }
    } catch (e) {
      debugPrint('❌ 디바이스 정보 요청 실패: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDF8FF), Color(0xFFE5F0FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1 / 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF6A4DFF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '환영합니다!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF090A0A),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '홈캠에 QR코드를 이용해 앱과 연동해 주세요!',
                      style: TextStyle(fontSize: 16, color: Color(0xFF090A0A)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              qrData != null
                  ? QrImageView(
                    data: qrData!,
                    version: QrVersions.auto,
                    size: 240,
                  )
                  : const CircularProgressIndicator(),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _completeSetupAndGoHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6A4DFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
