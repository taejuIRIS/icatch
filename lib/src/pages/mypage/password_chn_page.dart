import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart'; // ✅ API 분리된 부분 import

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      _showDialog(
        title: "비밀번호 불일치",
        content: "비밀번호가 일치하지 않습니다.\n다시 한 번 기입해 주세요.",
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      _showDialog(title: "인증 오류", content: "로그인이 필요합니다.");
      return;
    }

    final result = await ApiService.changePassword(
      token: token,
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    if (result['statusCode'] == 200) {
      _showDialog(
        title: "비밀번호 변경 완료",
        content: "비밀번호가 성공적으로 변경되었습니다!",
        onConfirm: () => Navigator.pop(context),
      );
    } else {
      _showDialog(
        title: "변경 실패",
        content: result['data']['message'] ?? '비밀번호 변경에 실패했습니다.',
      );
    }
  }

  void _showDialog({
    required String title,
    required String content,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onConfirm != null) onConfirm();
                },
                child: const Text("확인", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("비밀번호 수정"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildPasswordField("기존 비밀번호", _currentPasswordController),
            const SizedBox(height: 16),
            _buildPasswordField("새로운 비밀번호", _newPasswordController),
            const SizedBox(height: 16),
            _buildPasswordField("새로운 비밀번호 확인", _confirmPasswordController),
            const Spacer(),
            GestureDetector(
              onTap: _changePassword,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A4DFF),
                  borderRadius: BorderRadius.circular(40),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Done",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF344053),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: "",
          ),
        ),
      ],
    );
  }
}
