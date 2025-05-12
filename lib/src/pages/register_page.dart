import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../styles/input_styles.dart';
import '../../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final res = await ApiService.register(
      email: _emailController.text.trim(),
      nickname: _nicknameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (res['success']) {
      await showCupertinoDialog(
        context: context,
        builder:
            (_) => CupertinoAlertDialog(
              title: const Text('🎉 회원가입 성공!'),
              content: const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('이제 로그인 해 주세요.'),
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(context); // 닫기
                    Navigator.pop(context); // 로그인 화면으로 돌아가기
                  },
                  child: const Text('확인'),
                ),
              ],
            ),
      );
    } else {
      await showCupertinoDialog(
        context: context,
        builder:
            (_) => CupertinoAlertDialog(
              title: const Text(
                '중복된 이메일입니다!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('이메일을 다시 작성해 주세요!'),
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
          '회원가입',
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Contact us',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6A4DFF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'i',
                    style: TextStyle(color: Color(0xFF090A0A)),
                  ),
                  TextSpan(
                    text: 'Catch',
                    style: TextStyle(color: Color(0xFF6A4DFF)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'iCatch에 오신 것을 환영합니다. 회원 가입 후\n편리하게 내 집을 지키세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF667084)),
            ),
            const SizedBox(height: 40),

            _buildInputField(
              label: 'Nickname',
              controller: _nicknameController,
              hintText: 'nickname',
            ),
            const SizedBox(height: 20),

            _buildInputField(
              label: 'Email',
              controller: _emailController,
              hintText: 'youre@email.com',
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

            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A4DFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(48),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '회원가입',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
