//import 'dart:async';
//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
//import 'package:http/http.dart' as http;

class CameraMonitorView extends StatefulWidget {
  final String deviceIP;

  const CameraMonitorView({super.key, required this.deviceIP});

  @override
  State<CameraMonitorView> createState() => _CameraMonitorViewState();
}

class _CameraMonitorViewState extends State<CameraMonitorView> {
  late final WebViewController _controller;
  bool isInitialized = false;
  bool isError = false;

  // Timer? _statusTimer;
  // String? _previousStatus; // 이전 상태 저장용

  @override
  void initState() {
    super.initState();

    if (widget.deviceIP.isEmpty) {
      setState(() => isError = true);
      return;
    }

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.black)
          ..setNavigationDelegate(
            NavigationDelegate(
              onWebResourceError: (error) {
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

    setState(() => isInitialized = true);

    // 🔕 블랙스크린 상태 체크 비활성화
    // _startStatusCheck();
  }

  // void _startStatusCheck() {
  //   _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
  //     try {
  //       final res = await http.get(Uri.parse('${widget.deviceIP}/screen_status'));

  //       if (res.statusCode == 200) {
  //         final status = jsonDecode(res.body); // "on" 또는 "off" 문자열 기대

  //         if (_previousStatus != null && _previousStatus != status) {
  //           debugPrint('📡 상태 변경 감지됨: $_previousStatus → $status');
  //           _reloadWebView(); // 상태 변화가 감지되면 새로고침
  //         }

  //         _previousStatus = status; // 현재 상태를 저장
  //       }
  //     } catch (e) {
  //       debugPrint('📛 screen_status 체크 실패: $e');
  //     }
  //   });
  // }

  void _reloadWebView() {
    setState(() {
      isError = false;
    });

    _controller.loadRequest(
      Uri.parse('${widget.deviceIP}/video_feed'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );
  }

  @override
  void didUpdateWidget(covariant CameraMonitorView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.deviceIP != widget.deviceIP) {
      _controller.loadRequest(
        Uri.parse('${widget.deviceIP}/video_feed'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );
    }
  }

  @override
  void dispose() {
    // _statusTimer?.cancel(); // 타이머 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isError || widget.deviceIP.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '카메라 연결에 실패했어요 😢',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _reloadWebView,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('다시 시도하기'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child:
          isInitialized
              ? WebViewWidget(controller: _controller)
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
