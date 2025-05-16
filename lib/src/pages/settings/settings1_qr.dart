import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../../components/wifi_setup_modal.dart';
import '../../../services/api_service.dart';
import 'settings2_checkqr.dart';

final Logger logger = Logger();

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
                'password': _passwordController.text,
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
    await prefs.setBool('isSetup_${widget.userId}', true);

    final deviceInfo = await ApiService.fetchDeviceInfo(widget.userId);
    logger.i('✅ 디바이스 정보: $deviceInfo');

    if (!mounted) return;

    if (deviceInfo != null) {
      await prefs.setInt('cameraId_${widget.userId}', deviceInfo['cameraId']);
      await prefs.setInt('deviceId_${widget.userId}', deviceInfo['deviceId']);
      await prefs.setString(
        'deviceIP_${widget.userId}',
        deviceInfo['deviceIP'],
      );

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔙 뒤로 가기 버튼
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 12),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 12),

              // 🔵 진행 바
              Center(
                child: Container(
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
              ),
              const SizedBox(height: 48),

              // 👋 환영 메시지
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

              // 📷 QR 코드
              Center(
                child:
                    qrData != null
                        ? QrImageView(
                          data: qrData!,
                          version: QrVersions.auto,
                          size: 240,
                        )
                        : const CircularProgressIndicator(),
              ),

              const Spacer(),

              // ✅ 계속 버튼
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
