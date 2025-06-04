import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CameraMonitorView extends StatefulWidget {
  final String deviceIP;

  const CameraMonitorView({super.key, required this.deviceIP});

  @override
  State<CameraMonitorView> createState() => _CameraMonitorViewState();
}

class _CameraMonitorViewState extends State<CameraMonitorView> {
  IO.Socket? socket;
  ui.Image? image;
  DateTime? _lastFrameTime;
  bool isDecoding = false;

  @override
  void initState() {
    super.initState();

    debugPrint('🔍 전달받은 deviceIP: ${widget.deviceIP}');
    if (widget.deviceIP.isEmpty) return;

    _initSocket();
  }

  void _initSocket() {
    final rawUrl = widget.deviceIP.trim();
    final url = rawUrl.startsWith('http') ? rawUrl : 'http://$rawUrl';

    debugPrint('📡 소켓 연결 시도: $url');

    socket?.disconnect();
    socket?.destroy();

    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'ngrok-skip-browser-warning': 'true'})
          .disableAutoConnect()
          .build(),
    );

    socket!
      ..onConnect((_) {
        debugPrint('✅ 소켓 연결됨');
        socket!.emit('start_stream');
      })
      ..on('video_frame', (data) {
        final now = DateTime.now();
        if (_lastFrameTime != null &&
            now.difference(_lastFrameTime!) <
                const Duration(milliseconds: 100)) {
          return;
        }
        _lastFrameTime = now;

        if (isDecoding) return;
        isDecoding = true;

        try {
          if (data is String) {
            final bytes = base64Decode(data);
            ui.decodeImageFromList(Uint8List.fromList(bytes), (decodedImg) {
              if (!mounted) return;
              setState(() {
                image = decodedImg;
                isDecoding = false;
              });
              debugPrint('📸 프레임 수신');
            });
          } else {
            throw Exception('잘못된 형식: ${data.runtimeType}');
          }
        } catch (e) {
          debugPrint('❌ 프레임 디코딩 오류: $e');
          isDecoding = false;
        }
      })
      ..onConnectError((err) {
        debugPrint('❌ 연결 오류: $err');
      })
      ..onDisconnect((_) {
        debugPrint('⚠️ 소켓 연결 종료됨');
        // 연결 종료되어도 image는 그대로 유지 (에러 표시 없음)
      });

    socket!.connect();
  }

  @override
  void dispose() {
    socket?.disconnect();
    socket?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child:
          image != null
              ? CustomPaint(
                painter: VideoPainter(image!),
                child: const SizedBox.expand(),
              )
              : const Center(child: Text('영상 수신 중...')),
    );
  }
}

class VideoPainter extends CustomPainter {
  final ui.Image image;

  VideoPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(covariant VideoPainter oldDelegate) => true;
}
