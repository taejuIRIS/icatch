import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CameraMonitorView extends StatelessWidget {
  final String deviceIP;

  const CameraMonitorView({super.key, required this.deviceIP});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('$deviceIP/video_feed'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

    return Container(
      width: double.infinity,
      height: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
