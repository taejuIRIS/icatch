import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import '../../components/camera_monitor_view.dart';

class DeviceDangerZonePage extends StatefulWidget {
  final int cameraId;
  final int deviceId;
  final String deviceIP;

  const DeviceDangerZonePage({
    super.key,
    required this.cameraId,
    required this.deviceId,
    required this.deviceIP,
  });

  @override
  State<DeviceDangerZonePage> createState() => _DeviceDangerZonePageState();
}

class _DeviceDangerZonePageState extends State<DeviceDangerZonePage> {
  final List<int> selectedZones = [];
  bool isLoading = false;

  void toggleZone(int zone) {
    setState(() {
      if (selectedZones.contains(zone)) {
        selectedZones.remove(zone);
      } else {
        selectedZones.add(zone);
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (selectedZones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 하나 이상의 위험 구역을 선택해 주세요.')),
      );
      return;
    }

    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('인증 정보가 없습니다. 로그인이 필요합니다.')));
      return;
    }

    final result = await ApiService.setDangerZones(
      cameraId: widget.cameraId,
      zones: selectedZones,
      token: token,
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
        arguments: {'navigateFrom': 'deviceRegister', 'isNewlyAdded': true},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? '위험 구역 설정 실패')),
      );
    }
  }

  Widget _buildZoneOverlay() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          CameraMonitorView(deviceIP: widget.deviceIP),
          Positioned.fill(
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 142 / 80,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
              children: List.generate(9, (index) {
                final zone = index + 1;
                final isSelected = selectedZones.contains(zone);
                return GestureDetector(
                  onTap: () => toggleZone(zone),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0x446A4DFF)
                              : Colors.transparent,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                );
              }),
            ),
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
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'i',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: 'Catch',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A4DFF),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 6 / 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A4DFF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '얼마 안 남았어요!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF090A0A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'iCatch는 보호 대상이 위험 구역에 있을 때 사용자 님께\n위험 감지 알림을 보내 드려요! 위험 구역을 설정해 볼까요?\n아홉 개 구간 중 위험하다고 생각하는 구간을 눌러주시면 돼요!',
                style: TextStyle(fontSize: 16, color: Color(0xFF090A0A)),
              ),
              const SizedBox(height: 24),
              _buildZoneOverlay(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Done',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
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
