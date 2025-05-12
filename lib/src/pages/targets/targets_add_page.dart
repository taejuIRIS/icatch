import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../../../services/api_service.dart';

final Logger logger = Logger();

class TargetsAddPage extends StatefulWidget {
  const TargetsAddPage({super.key});

  @override
  State<TargetsAddPage> createState() => _TargetsAddPageState();
}

class _TargetsAddPageState extends State<TargetsAddPage> {
  String? selectedTarget;
  bool isLoading = false;

  late int cameraId;
  late int deviceId;
  late String deviceIP;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      cameraId = args['cameraId'];
      deviceId = args['deviceId'];
      deviceIP = args['deviceIP'];
      logger.i(
        '[TargetsAddPage] 전달받은 cameraId: $cameraId, deviceId: $deviceId, deviceIP: $deviceIP',
      );
    } else {
      logger.e('❗ settings.arguments가 null이거나 잘못된 타입입니다.');
      Navigator.pop(context);
    }
  }

  Future<void> _submitTarget() async {
    if (selectedTarget == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('대상을 선택해 주세요.')));
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

    final String targetType = selectedTarget == '사람' ? 'person' : 'pet';
    setState(() => isLoading = true);

    logger.i('[TargetsAddPage] 선택된 대상: $selectedTarget ($targetType)');
    logger.i('[TargetsAddPage] userId: $userId, cameraId: $cameraId');

    final result = await ApiService.setTargetType(
      userId: userId,
      cameraId: cameraId,
      targetType: targetType,
    );

    logger.i('[TargetsAddPage] API 응답: $result');

    if (!mounted) return;
    setState(() => isLoading = false);

    if (result['success']) {
      Navigator.pop(context, {
        'cameraId': cameraId,
        'deviceId': deviceId,
        'targetType': targetType,
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'] ?? '대상 설정 실패')));
    }
  }

  Widget _buildOption(String label) {
    final isSelected = selectedTarget == label;
    return GestureDetector(
      onTap: () => setState(() => selectedTarget = label),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE7E7FF) : Colors.white,
          border: Border.all(
            color:
                isSelected ? const Color(0xFF6A4DFF) : const Color(0xFFF2F4F5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(48),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color:
                isSelected ? const Color(0xFF6A4DFF) : const Color(0xFF090A0A),
          ),
        ),
      ),
    );
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
                  widthFactor: 6 / 6,
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
                '우리 집에 누가 살고 있나요?',
                style: TextStyle(fontSize: 16, color: Color(0xFF090A0A)),
              ),
              const SizedBox(height: 24),
              _buildOption('사람'),
              const SizedBox(height: 12),
              _buildOption('반려동물'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitTarget,
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
                            'Done',
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
