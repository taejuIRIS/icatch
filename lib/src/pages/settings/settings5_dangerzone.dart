import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../services/api_service.dart';

class SettingsDangerZonePage extends StatefulWidget {
  final int cameraId;
  final int deviceId;
  final String deviceIP;

  const SettingsDangerZonePage({
    super.key,
    required this.cameraId,
    required this.deviceId,
    required this.deviceIP,
  });

  @override
  State<SettingsDangerZonePage> createState() => _SettingsDangerZonePageState();
}

class _SettingsDangerZonePageState extends State<SettingsDangerZonePage> {
  final List<int> selectedZones = [];
  bool isLoading = false;
  bool isWebError = false;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onWebResourceError: (error) {
                setState(() => isWebError = true);
              },
            ),
          )
          ..loadRequest(
            Uri.parse('${widget.deviceIP}/video_feed'),
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true',
            },
          );
  }

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

    print('[DangerZone] token: $token');
    print('[DangerZone] 선택된 구역: $selectedZones');

    final result = await ApiService.setDangerZones(
      cameraId: widget.cameraId,
      zones: selectedZones,
      token: token,
    );

    print('[DangerZone] 응답 결과: $result');

    setState(() => isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      Navigator.pushNamed(
        context,
        '/settingsGesture',
        arguments: {
          'cameraId': widget.cameraId,
          'deviceId': widget.deviceId,
          'deviceIP': widget.deviceIP,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? '위험 구역 설정 실패')),
      );
    }
  }

  Widget _buildZoneOverlay() {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: AspectRatio(
          aspectRatio: 16 / 9, // 1280x720 비율 유지
          child: Stack(
            children: [
              if (isWebError)
                const Center(
                  child: Text(
                    '📡 영상 스트리밍을 불러오지 못했어요!',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              else
                WebViewWidget(controller: _controller),

              GridView.count(
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 5 / 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A4DFF),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  '얼마 안 남았어요!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF090A0A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'iCatch는 보호 대상이 위험 구역에 있을 때 사용자 님께\n알림을 보내드려요! 위험 구역을 설정해 볼까요?\n총 9개 구간 중 위험하다고 생각하는 구간을 눌러주세요!',
                  style: TextStyle(fontSize: 16, color: Color(0xFF090A0A)),
                ),
                const SizedBox(height: 16),

                _buildZoneOverlay(),

                const SizedBox(height: 40),
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
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Continue',
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
      ),
    );
  }
}
