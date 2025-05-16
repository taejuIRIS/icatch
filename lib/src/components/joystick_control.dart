import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class JoystickControl extends StatelessWidget {
  final String deviceIP;

  const JoystickControl({super.key, required this.deviceIP});

  Future<void> _handleDirection(String direction) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null || token.isEmpty) {
      logger.i('❌ 토큰 없음');
      return;
    }

    final url = Uri.parse('$deviceIP/servo');
    // final url = Uri.parse('https://9c7b-210-119-237-42.ngrok-free.app/servo');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'direction': direction});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        logger.i('✅ [$direction] 성공: ${response.body}');
      } else {
        logger.w(
          '⚠️ [$direction] 실패: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      logger.e('❌ 요청 실패: $e');
    }
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

            // 중앙 버튼 (center)
            GestureDetector(
              onTap: () => _handleDirection("center"),
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6A4DFF),
                ),
              ),
            ),

            // 좌측 화살표
            Positioned(
              left: 10,
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
              right: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_right,
                  size: 40,
                  color: Color(0xFF6A4DFF),
                ),
                onPressed: () => _handleDirection("right"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
