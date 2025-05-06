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
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF7A5FFF),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: currentIndex == 0 ? const Color(0xFF7A5FFF) : Colors.grey,
          ),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.calendar_today,
            color: currentIndex == 1 ? const Color(0xFF7A5FFF) : Colors.grey,
          ),
          label: '캘린더',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.add_circle_outline,
            size: 28,
            color: currentIndex == 2 ? const Color(0xFF7A5FFF) : Colors.grey,
          ),
          label: '추가',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.notifications_none,
            color: currentIndex == 3 ? const Color(0xFF7A5FFF) : Colors.grey,
          ),
          label: '알림',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 4 ? Icons.person : Icons.person_outline,
            color: currentIndex == 4 ? const Color(0xFF7A5FFF) : Colors.grey,
          ),
          label: '프로필',
        ),
      ],
    );
  }
}
