import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF7A5FFF), // ✅ 선택 색상
      unselectedItemColor: Colors.grey, // ✅ 비선택 색상
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: '홈'),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline, size: 30),
          label: '추가',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none, size: 30),
          label: '알림',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: 30),
          label: '프로필',
        ),
      ],
    );
  }
}
