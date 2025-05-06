import 'package:flutter/material.dart';

class SettingsDangerZonePage extends StatefulWidget {
  const SettingsDangerZonePage({super.key});

  @override
  State<SettingsDangerZonePage> createState() => _SettingsDangerZonePageState();
}

class _SettingsDangerZonePageState extends State<SettingsDangerZonePage> {
  // 예시로 3x3 영역을 선택할 수 있도록 구성
  List<bool> selectedZones = List.generate(9, (_) => false);

  void _handleDone() {
    // TODO: 선택된 zones 데이터를 서버에 전송하는 로직 추가 가능

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/deviceList', // 홈 화면의 라우트 네임
      (route) => false,
    );
  }

  Widget _buildZoneGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final isSelected = selectedZones[index];
        return GestureDetector(
          onTap: () {
            setState(() => selectedZones[index] = !isSelected);
          },
          child: Container(
            decoration: BoxDecoration(
              color:
                  isSelected ? const Color(0x886A4DFF) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '얼마 안 남았어요!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF090A0A),
                ),
              ),
              const SizedBox(height: 8),
              const Text('위험 구역을 설정해 주세요!', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              _buildZoneGrid(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
