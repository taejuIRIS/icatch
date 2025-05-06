import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class JoystickControl extends StatelessWidget {
  final int cameraId;
  const JoystickControl({super.key, required this.cameraId});

  Future<void> _handleDirection(String direction) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null || token.isEmpty) {
      print('❌ 토큰 없음');
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
      margin: const EdgeInsets.only(top: 24),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/joystick.png',
              width: 160,
              height: 160,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 20,
              child: IconButton(
                icon: const Icon(Icons.keyboard_arrow_up, size: 36, color: Color(0xFF7A5FFF)),
                onPressed: () => _handleDirection("up"),
              ),
            ),
            Positioned(
              bottom: 20,
              child: IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, size: 36, color: Color(0xFF7A5FFF)),
                onPressed: () => _handleDirection("down"),
              ),
            ),
            Positioned(
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.keyboard_arrow_left, size: 36, color: Color(0xFF7A5FFF)),
                onPressed: () => _handleDirection("left"),
              ),
            ),
            Positioned(
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.keyboard_arrow_right, size: 36, color: Color(0xFF7A5FFF)),
                onPressed: () => _handleDirection("right"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
