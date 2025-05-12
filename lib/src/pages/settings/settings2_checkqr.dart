import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:logger/logger.dart';
import 'settings3_camname.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ 추가

final Logger logger = Logger();

class CheckMonitoringPage extends StatefulWidget {
  final int cameraId;
  final int deviceId;
  final String deviceIP;

  const CheckMonitoringPage({
    super.key,
    required this.cameraId,
    required this.deviceId,
    required this.deviceIP,
  });

  @override
  State<CheckMonitoringPage> createState() => _CheckMonitoringPageState();
}

class _CheckMonitoringPageState extends State<CheckMonitoringPage> {
  bool isError = false;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    logger.i('📡 받은 deviceIP: ${widget.deviceIP}');
    logger.i('📡 받은 cameraId: ${widget.cameraId}');
    logger.i('📡 받은 deviceId: ${widget.deviceId}');

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onWebResourceError: (error) {
                logger.e('❌ WebView 로딩 실패: ${error.description}');
                setState(() => isError = true);
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

  Future<void> _completeSetupAndGoNext() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;

    await prefs.setBool('isSetupComplete_${userId}', true);
    await prefs.setInt('cameraId_${userId}', widget.cameraId);
    await prefs.setInt('deviceId_${userId}', widget.deviceId);
    await prefs.setString('deviceIP_${userId}', widget.deviceIP);

    logger.i('✅ 장치 정보 저장 완료');

    if (!mounted) return;

    logger.i('➡️ SettingsCamNamePage로 이동');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => SettingsCamNamePage(
              deviceId: widget.deviceId,
              deviceIP: widget.deviceIP,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 12),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 2 / 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A4DFF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '잘하셨습니다!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF090A0A),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '화면이 잘 보이는 지 확인해 주세요!',
                    style: TextStyle(fontSize: 16, color: Color(0xFF090A0A)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child:
                      isError
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('영상을 불러오는 데 실패했어요 😢'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  logger.i('🔄 WebView 재시도');
                                  setState(() {
                                    isError = false;
                                    _controller.loadRequest(
                                      Uri.parse(
                                        '${widget.deviceIP}/video_feed',
                                      ),
                                      headers: {
                                        'Content-Type': 'application/json',
                                        'ngrok-skip-browser-warning': 'true',
                                      },
                                    );
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6A4DFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text('다시 시도하기'),
                              ),
                            ],
                          )
                          : WebViewWidget(controller: _controller),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _completeSetupAndGoNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
