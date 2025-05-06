// ✅ settings6_gestures.dart 수정 완료본
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import '../../components/gesture_func_modal.dart';

class SettingsGesturePage extends StatefulWidget {
  final int cameraId;
  final int deviceId;
  final String deviceIP;

  const SettingsGesturePage({
    super.key,
    required this.cameraId,
    required this.deviceId,
    required this.deviceIP,
  });

  @override
  State<SettingsGesturePage> createState() => _SettingsGesturePageState();
}

class _SettingsGesturePageState extends State<SettingsGesturePage> {
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
      'name': '가위 제스처',
      'description': '가위 모양 손동작',
      'image': 'assets/images/Gestures/Gesture_scissors.png',
    },
    {
      'name': '위 손동작',
      'description': '손을 위로 향한 제스처',
      'image': 'assets/images/Gestures/Gesture_top.png',
    },
    {
      'name': '엄지 위로',
      'description': '엄지 위로 제스처',
      'image': 'assets/images/Gestures/Gesture_up.png',
    },
    {
      'name': 'X 손동작',
      'description': '손으로 X자 모양',
      'image': 'assets/images/Gestures/Gesture_X.png',
    },
  ];

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
      cameraId: widget.cameraId,
      gestureName: selected['name']!,
      gestureType: 'hand',
      gestureDescription: selected['description']!,
      gestureImagePath: selected['image']!,
      selectedFunction: selectedFunction!,
    );

    setState(() => isLoading = false);
    if (!mounted) return;

    if (result['success']) {
      await prefs.setBool('isSetupComplete', true);
      await prefs.setInt('cameraId', widget.cameraId);
      await prefs.setInt('deviceId', widget.deviceId);
      await prefs.setString('deviceIP', widget.deviceIP);

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
        arguments: {
          'cameraId': widget.cameraId,
          'deviceId': widget.deviceId,
          'deviceIP': widget.deviceIP,
        },
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'] ?? '제스처 등록 실패')));
    }
  }

  Future<void> _onGestureTap(int index) async {
    setState(() => selectedIndex = index);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => GestureFuncModal(
            selectedFunction: selectedFunction,
            onSelect: (value) => Navigator.pop(context, value),
          ),
    );

    if (result != null) {
      setState(() => selectedFunction = result);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 6),
              Container(
                height: 6,
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
              const SizedBox(height: 32),
              const Text(
                '마지막으로',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '제스처를 등록할까요? 사용하실 손동작을 선택해 주세요!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                                color: Colors.deepPurple.withOpacity(0.35),
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
              const SizedBox(height: 16),
              SizedBox(
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
