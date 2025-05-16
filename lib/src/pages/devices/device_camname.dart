import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

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

    logger.i('📦 API 응답: $result');

    if (!mounted) return;
    setState(() => _isLoading = false);

    final cameraId = result['cameraId'];

    if (result['success'] == true && cameraId != null) {
      Navigator.pushNamed(
        context,
        '/DeviceDangerZonePage',
        arguments: {
          'cameraId': cameraId,
          'deviceId': widget.deviceId,
          'deviceIP': widget.deviceIP,
        },
      );
    } else {
      final message = result['message'] ?? '카메라 ID를 받아오지 못했습니다.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 3 / 4,
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
