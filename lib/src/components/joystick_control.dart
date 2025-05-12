import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class JoystickControl extends StatelessWidget {
  final int cameraId;
  const JoystickControl({super.key, required this.cameraId});

  Future<void> _handleDirection(String direction) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null || token.isEmpty) {
      logger.i('❌ 토큰 없음');
      return;
    }

    await ApiService.controlCameraDirection(
      cameraId: cameraId,
      direction: direction,
      token: token,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 바깥 원
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDFF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      255,
                      103,
                      58,
                      183,
                    ).withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),

            // 상단 화살표
            Positioned(
              top: 24,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_drop_up,
                  size: 40,
                  color: Color(0xFF6A4DFF),
                ),
                onPressed: () => _handleDirection("up"),
              ),
            ),

            // 하단 화살표
            Positioned(
              bottom: 24,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_drop_down,
                  size: 40,
                  color: Color(0xFF6A4DFF),
                ),
                onPressed: () => _handleDirection("down"),
              ),
            ),

            // 좌측 화살표
            Positioned(
              left: 24,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_left,
                  size: 40,
                  color: Color(0xFF6A4DFF),
                ),
                onPressed: () => _handleDirection("left"),
              ),
            ),

            // 우측 화살표
            Positioned(
              right: 24,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_right,
                  size: 40,
                  color: Color(0xFF6A4DFF),
                ),
                onPressed: () => _handleDirection("right"),
              ),
            ),

            // 중앙 버튼
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF6A4DFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
