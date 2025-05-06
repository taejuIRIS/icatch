import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/input_styles.dart';
import '../../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    print('📤 로그인 요청: email=$email, password=$password');

    final res = await ApiService.login(email: email, password: password);

    print('📥 로그인 응답: $res');

    if (!mounted) return;

    if (res['success']) {
      final token = res['data']['token'];
      final userId = res['data']['userId'];

      print('✅ 로그인 성공 - token: $token');
      print('✅ 로그인 성공 - userId: $userId');

      if (token == null || token.isEmpty || userId == null) {
        print('❌ token 또는 userId가 null');
        _showError('로그인 실패: 사용자 정보가 없습니다.');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      await prefs.setInt('userId', userId);
      print('📦 토큰 저장 완료');

      final isSetupComplete = prefs.getBool('isSetupComplete') ?? false;
      final cameraId = prefs.getInt('cameraId');
      final deviceId = prefs.getInt('deviceId');
      final deviceIP = prefs.getString('deviceIP');

      print('🧾 설정 여부: $isSetupComplete');
      print('🧾 cameraId: $cameraId, deviceId: $deviceId, deviceIP: $deviceIP');

      if (isSetupComplete &&
          cameraId != null &&
          deviceId != null &&
          deviceIP != null) {
        print('➡️ 홈으로 이동');
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {
            'cameraId': cameraId,
            'deviceId': deviceId,
            'deviceIP': deviceIP,
          },
        );
      } else {
        print('➡️ QR 설정 화면으로 이동');
        Navigator.pushReplacementNamed(
          context,
          '/settingsqr',
          arguments: userId,
        );
      }
    } else {
      print('❌ 로그인 실패 - 메시지: ${res['message']}');
      _showError(res['message'] ?? '이메일 혹은 비밀번호가 올바르지 않습니다.');
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: const Text(
              '로그인 실패',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(message),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '로그인',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF090A0A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              label: 'Email',
              controller: _emailController,
              hintText: 'example@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              label: 'Password',
              controller: _passwordController,
              hintText: 'password',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed:
                    () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A4DFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(48),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF344053),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: InputStyles.inputBoxDecoration,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputStyles.inputDecoration(
              hintText: hintText,
              suffixIcon: suffixIcon,
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
