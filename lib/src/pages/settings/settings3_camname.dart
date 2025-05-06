import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';

class SettingsCamNamePage extends StatefulWidget {
  final int deviceId;
  final String deviceIP; // ✅ 추가

  const SettingsCamNamePage({
    super.key,
    required this.deviceId,
    required this.deviceIP, // ✅ 추가
  });

  @override
  State<SettingsCamNamePage> createState() => _SettingsCamNamePageState();
}

class _SettingsCamNamePageState extends State<SettingsCamNamePage> {
  final TextEditingController _camNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleContinue() async {
    final camName = _camNameController.text.trim();

    if (camName.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('카메라 이름을 입력해 주세요.')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('사용자 정보를 불러올 수 없습니다.')));
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.createCameraName(
      userId: userId,
      deviceId: widget.deviceId,
      name: camName,
    );

    print('📦 API 응답: $result');

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true || result['success'].toString() == 'true') {
      final data = result['data'];
      if (data == null || data['cameraId'] == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('카메라 ID를 받아오지 못했습니다.')));
        return;
      }

      final int cameraId = data['cameraId'];

      Navigator.pushNamed(
        context,
        '/settingsTargets',
        arguments: {
          'cameraId': cameraId,
          'deviceId': widget.deviceId,
          'deviceIP': widget.deviceIP, // ✅ 전달
          'camName': camName,
        },
      );
    } else {
      final message = result['message'] ?? '카메라 이름 설정 실패';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
                '멋지네요!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF090A0A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '홈캠을 두신 위치를 알려 주세요!',
                style: TextStyle(fontSize: 16, color: Color(0xFF090A0A)),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _camNameController,
                decoration: InputDecoration(
                  hintText: '예: 안방, 거실, 창문 근처 등',
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
                  onPressed: _isLoading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child:
                      _isLoading
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
