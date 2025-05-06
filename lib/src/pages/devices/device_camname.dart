import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';

class DeviceCamNamePage extends StatefulWidget {
  final int deviceId;
  final String deviceIP;

  const DeviceCamNamePage({
    super.key,
    required this.deviceId,
    required this.deviceIP,
  });

  @override
  State<DeviceCamNamePage> createState() => _DeviceCamNamePageState();
}

class _DeviceCamNamePageState extends State<DeviceCamNamePage> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  Future<void> _submit() async {
    final camName = _controller.text.trim();
    if (camName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("카메라 이름을 입력해 주세요.")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;

    setState(() => isLoading = true);

    final result = await ApiService.createCameraName(
      userId: userId,
      deviceId: widget.deviceId,
      name: camName,
    );

    setState(() => isLoading = false);

    if (result['success'] == true) {
      final cameraId = result['data']['cameraId'];
      Navigator.pushNamed(
        context,
        '/settingsTargets',
        arguments: {
          'cameraId': cameraId,
          'deviceId': widget.deviceId,
          'deviceIP': widget.deviceIP,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "카메라 이름 설정 실패")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              // 진행바
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 3 / 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A4DFF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                '좋아요!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF090A0A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '이번 홈캠은 어디에 두시나요?',
                style: TextStyle(fontSize: 16, color: Color(0xFF090A0A)),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '예: 거실, 부엌, 현관',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: const BorderSide(color: Color(0xFFE3E4E5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Continue',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
