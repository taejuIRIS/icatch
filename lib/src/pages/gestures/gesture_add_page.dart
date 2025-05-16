import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../services/api_service.dart';
import '../../components/gesture_func_modal.dart';
import '../../../utils/shared_pref_helper.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class GestureAddPage extends StatefulWidget {
  const GestureAddPage({super.key});

  @override
  State<GestureAddPage> createState() => _GestureAddPageState();
}

class _GestureAddPageState extends State<GestureAddPage> {
  late int cameraId;
  late int deviceId;
  late String deviceIP;

  int? selectedIndex;
  String? selectedFunction;
  bool isLoading = false;

  final List<Map<String, String>> gestures = [
    {
      'name': '손가락 0개',
      'description': '손가락 0개 제스처',
      'image': 'assets/images/Gestures/Gesture_0.png',
    },
    {
      'name': '손가락 1개',
      'description': '손가락 1개 제스처',
      'image': 'assets/images/Gestures/Gesture_1.png',
    },
    {
      'name': '손가락 2개',
      'description': '손가락 2개 제스처',
      'image': 'assets/images/Gestures/Gesture_2.png',
    },
    {
      'name': '손가락 3개',
      'description': '손가락 3개 제스처',
      'image': 'assets/images/Gestures/Gesture_3.png',
    },
    {
      'name': '손가락 4개',
      'description': '손가락 4개 제스처',
      'image': 'assets/images/Gestures/Gesture_4.png',
    },
    {
      'name': '손가락 5개',
      'description': '손가락 5개 제스처',
      'image': 'assets/images/Gestures/Gesture_5.png',
    },
    {
      'name': '아래 손동작',
      'description': '손을 아래로 향한 제스처',
      'image': 'assets/images/Gestures/Gesture_down.png',
    },
    {
      'name': '약속 손동작',
      'description': '약속 손동작',
      'image': 'assets/images/Gestures/Gesture_prom.png',
    },
    {
      'name': '엄지 위로',
      'description': '엄지 위로 제스처',
      'image': 'assets/images/Gestures/Gesture_up.png',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      cameraId = args['cameraId'] ?? 1;
      deviceId = args['deviceId'] ?? 1;
      deviceIP = args['deviceIP'] ?? '192.168.0.100';
    } else {
      cameraId = 1;
      deviceId = 1;
      deviceIP = '192.168.0.100';
    }
  }

  Future<void> _submitGesture() async {
    if (selectedIndex == null || selectedFunction == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제스처와 기능을 모두 선택해 주세요.')));
      return;
    }

    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (!mounted) return;

    if (userId == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인 정보가 없습니다.')));
      return;
    }

    final selected = gestures[selectedIndex!];
    final result = await ApiService.createGestureWithFunction(
      userId: userId,
      cameraId: cameraId,
      gestureName: selected['name']!,
      gestureType: 'hand',
      gestureDescription: selected['description']!,
      gestureImagePath: selected['image']!,
      selectedFunction: selectedFunction!,
      actionId: selectedIndex! + 1,
    );

    setState(() => isLoading = false);
    if (!mounted) return;

    if (result['success']) {
      // SharedPreferences 저장
      await prefs.setBool('isSetupComplete', true);
      await prefs.setInt('cameraId', cameraId);
      await prefs.setInt('deviceId', deviceId);
      await prefs.setString('deviceIP', deviceIP);

      await SharedPrefHelper.saveFunctionForGesture(
        selectedIndex! + 1,
        selectedFunction!,
      );

      // ✅ 디바이스에 제스처 전송
      final gestureId =
          selected['image']!.split('/').last.split('.').first; // ex: Gesture_0
      final deviceUrl = '$deviceIP/register_gesture';

      try {
        final response = await http.post(
          Uri.parse(deviceUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'gesture_id': gestureId,
            'action_id': selectedFunction!,
          }),
        );

        if (response.statusCode == 200) {
          logger.i('디바이스에 제스처 전송 성공');
        } else {
          logger.i('디바이스 전송 실패: ${response.statusCode}');
          logger.i('응답: ${response.body}');
        }
      } catch (e) {
        logger.i('디바이스 통신 오류: $e');
      }

      // 페이지 이동
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/AddPage',
        (route) => false,
        arguments: {
          'cameraId': cameraId,
          'deviceId': deviceId,
          'deviceIP': deviceIP,
        },
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'] ?? '제스처 등록 실패')));
    }
  }

  Future<void> _onGestureTap(int index) async {
    setState(() {
      selectedIndex = index;
      selectedFunction = null;
    });

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => GestureFuncModal(
            selectedFunction: selectedFunction,
            onSelect: (_) {}, // 사용되지 않음
          ),
    );

    if (selected != null) {
      setState(() {
        selectedFunction = selected;
      });
    } else {
      setState(() {
        selectedIndex = null;
        selectedFunction = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Center(
                    child: Text.rich(
                      TextSpan(
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            _buildProgressBar(),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '제스처를 등록해 주세요!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '사용하실 손동작을 선택해 제스처로 홈캠을 제어해 봐요!',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  itemCount: gestures.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final gesture = gestures[index];
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () => _onGestureTap(index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(gesture['image']!, fit: BoxFit.cover),
                            if (isSelected)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.3),
                                  border: Border.all(
                                    color: Colors.deepPurple,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitGesture,
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}

Widget _buildProgressBar() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(100),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF6A4DFF),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    ),
  );
}
