import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import 'password_chn_page.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  Future<void> _deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text("로그인 토큰이 없습니다.")));
      return;
    }

    final result = await ApiService.deleteAccount(token);
    if (result['success']) {
      await prefs.clear(); // 모든 저장 정보 삭제
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원 탈퇴 실패: ${result['statusCode']}")),
      );
    }
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text(
              "회원 탈퇴",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text("정말로 탈퇴하시겠습니까?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("아니요", style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteAccount();
                },
                child: const Text("예", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ authToken만 제거
    await prefs.remove('authToken');

    if (!mounted) return;

    // 로그인 화면으로 이동
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('설정'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("비밀번호 변경"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("회원 탈퇴"),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showDeleteConfirmDialog,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Center(
              child: TextButton(
                onPressed: _logout,
                child: const Text(
                  "Log out",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
