import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
            Uri.parse(widget.deviceIP),
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true',
            },
          );

    setState(() => isInitialized = true);
  }

  void _reloadWebView() {
    setState(() {
      isError = false;
    });

    _controller.loadRequest(
      Uri.parse(widget.deviceIP),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );
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
