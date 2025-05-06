import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  List<Map<String, dynamic>> cameras = [];

  @override
  void initState() {
    super.initState();
    _fetchCameras();
  }

  Future<void> _fetchCameras() async {
    final url = Uri.parse('http://ceprj.gachon.ac.kr:60004/api/cameras/user');
    try {
      final response = await http.get(url);
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && decoded['success'] == true) {
        final List<dynamic> data = decoded['data'];
        setState(() {
          cameras = List<Map<String, dynamic>>.from(data);
        });
      } else {
        debugPrint('❌ 카메라 정보 조회 실패: ${decoded['message']}');
      }
    } catch (e) {
      debugPrint('❌ 예외 발생: $e');
    }
  }

  Widget _buildCameraItem(Map<String, dynamic> camera) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Image.asset('assets/icons/camera_baby.png', width: 64, height: 64),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  camera['cameraName'] ?? '카메라',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ip : ${camera['ipAddress'] ?? '●●●●●●●'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6C7072),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToQRPage() {
    Navigator.pushNamed(context, '/device_qr');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                '등록된 카메라 📸',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    cameras.isEmpty
                        ? const Center(child: Text('등록된 카메라가 없습니다.'))
                        : ListView.builder(
                          itemCount: cameras.length,
                          itemBuilder:
                              (context, index) =>
                                  _buildCameraItem(cameras[index]),
                        ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _goToQRPage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A4DFF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '카메라 등록!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'QR 코드를 통해 편리하게 카메라를 등록하세요!',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
