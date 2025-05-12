import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart'; // ✅ api_service 사용
import '../../components/wifi_setup_modal.dart';
import 'device_checkqr.dart';

class DeviceQRPage extends StatefulWidget {
  final int userId;
  const DeviceQRPage({super.key, required this.userId});

  @override
  State<DeviceQRPage> createState() => _DeviceQRPageState();
}

class _DeviceQRPageState extends State<DeviceQRPage> {
  String? qrData;
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showWifiModal());
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

  Future<void> _completeSetupAndGoNext() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSetup', true);

    final deviceInfo = await ApiService.fetchDeviceInfo(
      widget.userId,
    ); // ✅ api_service.dart 사용
    if (!mounted) return;

    if (deviceInfo != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => DeviceCheckQRPage(
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
                  widthFactor: 1 / 4,
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
                      '홈캠을 등록해 볼까요?',
                      style: TextStyle(
                        fontSize: 24,
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
                    onPressed: _completeSetupAndGoNext,
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
