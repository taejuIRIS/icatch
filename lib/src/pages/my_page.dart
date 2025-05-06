import 'package:flutter/material.dart';

class PersonalPage extends StatelessWidget {
  const PersonalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: Color(0xFF6A4DFF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 바
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.arrow_back),
                  Text(
                    "iCatch",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A4DFF),
                    ),
                  ),
                  SizedBox(width: 24),
                ],
              ),
            ),
            // 보라색 배경 영역
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              color: Color(0xFF6A4DFF),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(
                      "assets/images/profile.png",
                    ), // 본인 이미지로 교체
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "찬현",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "@chan1np",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
            // 통계 영역
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              color: Color(0xFFC6C4FF),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoCard(Icons.camera_alt, "3대"),
                  _buildInfoCard(Icons.pets, "반려 동물"),
                  _buildInfoCard(Icons.description, "32개"),
                ],
              ),
            ),
            // 메뉴 리스트
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(Icons.notifications, "알림", true),
                  _buildMenuItem(Icons.camera_alt, "카메라", false),
                  _buildMenuItem(Icons.pets, "주거인", false),
                  _buildMenuItem(Icons.photo_album, "앨범", false),
                  _buildMenuItem(Icons.settings, "설정", false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF6A4DFF), size: 32),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Color(0xFF6A4DFF))),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool hasToggle) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing:
          hasToggle
              ? Switch(
                value: true,
                onChanged: (val) {},
                activeColor: Color(0xFF6A4DFF),
              )
              : const Icon(Icons.chevron_right),
    );
  }
}
