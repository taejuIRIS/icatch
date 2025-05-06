import 'package:flutter/material.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // iCatch 로고 텍스트 분리
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'i',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Catch',
                      style: TextStyle(
                        color: Color(0xFF6A4DFF),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 로컬 이미지
              Image.asset('assets/images/baby-cat.png', height: 360),

              // 강조 텍스트
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF090A0A),
                  ),
                  children: [
                    const TextSpan(text: '계정을 생성하고 '),
                    TextSpan(
                      text: 'iCatch',
                      style: TextStyle(color: Color(0xFF6A4DFF)),
                    ),
                    const TextSpan(text: '를\n편리하게 사용하세요.'),
                  ],
                ),
              ),

              // 페이지 인디케이터
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_buildDot(false), _buildDot(false), _buildDot(true)],
              ),

              // 계정 생성 버튼 (텍스트 크기에 맞게)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A4DFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(48),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  '계정 생성하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // 로그인 텍스트
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '기존 계정이 있으신가요? ',
                    style: TextStyle(fontSize: 16, color: Color(0xFF202325)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6A4DFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6A4DFF) : const Color(0xFFE3E4E5),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
