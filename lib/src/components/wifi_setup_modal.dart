import 'package:flutter/material.dart';

class WifiSetupModal extends StatelessWidget {
  final TextEditingController ssidController;
  final TextEditingController passwordController;
  final VoidCallback onConfirm;

  const WifiSetupModal({
    super.key,
    required this.ssidController,
    required this.passwordController,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Wi-Fi 정보 입력'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ssidController,
              decoration: const InputDecoration(labelText: 'Wi-Fi 이름'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: '비밀번호 (선택)'),
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (ssidController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wi-Fi 이름을 입력해주세요')),
              );
              return;
            }
            onConfirm(); // ✅ 비밀번호는 없어도 통과
          },
          child: const Text('확인', style: TextStyle(color: Colors.deepPurple)),
        ),
      ],
    );
  }
}
