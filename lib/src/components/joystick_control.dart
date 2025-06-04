import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final Logger logger = Logger();

class JoystickControl extends StatefulWidget {
  final String deviceIP;

  const JoystickControl({super.key, required this.deviceIP});

  @override
  State<JoystickControl> createState() => _JoystickControlState();
}

class _JoystickControlState extends State<JoystickControl> {
  Timer? _repeatTimer;

  void _startRepeating(String direction) {
    _stopRepeating(); // 이전 타이머 정리
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      _sendDirection(direction);
    });
  }

  void _stopRepeating() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  Future<void> _sendDirection(String direction) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null || token.isEmpty) {
      logger.i('❌ 토큰 없음');
      return;
    }

    final url = Uri.parse('http://${widget.deviceIP}/servo');
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
  void dispose() {
    _stopRepeating();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
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

            // 중앙 버튼 (단일 요청)
            GestureDetector(
              onTap: () => _sendDirection("center"),
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6A4DFF),
                ),
              ),
            ),

            // 왼쪽 버튼
            Positioned(
              left: 10,
              child: GestureDetector(
                onTapDown: (_) => _startRepeating("left"),
                onTapUp: (_) => _stopRepeating(),
                onTapCancel: _stopRepeating,
                child: Container(
                  padding: const EdgeInsets.all(16), // 터치 영역 확장
                  child: const Icon(
                    Icons.arrow_left,
                    size: 40,
                    color: Color(0xFF6A4DFF),
                  ),
                ),
              ),
            ),

            // 오른쪽 버튼
            Positioned(
              right: 10,
              child: GestureDetector(
                onTapDown: (_) => _startRepeating("right"),
                onTapUp: (_) => _stopRepeating(),
                onTapCancel: _stopRepeating,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.arrow_right,
                    size: 40,
                    color: Color(0xFF6A4DFF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
