import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend1/services/api_service.dart';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  List<Map<String, dynamic>> _cameras = [];
  final Set<int> _selectedCameraIds = {};
  bool _selectionMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCameras();
  }

  Future<void> _fetchCameras() async {
    final cameras = await ApiService.fetchUserCameras2();
    setState(() {
      _cameras = cameras;
      _isLoading = false;
    });
  }

  Future<void> _deleteSelectedCameras() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('삭제 확인'),
            content: const Text('선택한 카메라를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('삭제'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      for (final id in _selectedCameraIds) {
        await ApiService.deleteCamera(id);
      }
      setState(() {
        _selectionMode = false;
        _selectedCameraIds.clear();
      });
      _fetchCameras();
    }
  }

  Future<void> _goToQRPage() async {
    if (_cameras.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('등록된 카메라가 없습니다.')));
      return;
    }

    final first = _cameras.first;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    await prefs.setInt('cameraId', first['cameraId']);
    await prefs.setInt('deviceId', first['deviceId']);
    await prefs.setString('deviceIP', first['deviceIp'] ?? '');

    Navigator.pushNamed(
      context,
      '/DeviceQRPage',
      arguments: {
        'userId': userId,
        'cameraId': first['cameraId'],
        'deviceId': first['deviceId'],
        'deviceIP': first['deviceIp'],
      },
    );
  }

  Widget _buildCameraCard(Map<String, dynamic> camera, int index) {
    final id = camera['cameraId'];
    final fullIp = camera['deviceIp']?.toString() ?? '';
    final maskedIp =
        fullIp.length >= 5
            ? '●●●●●●●${fullIp.substring(fullIp.length)}'
            : '●●●●●●●';

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _selectionMode = true;
          _selectedCameraIds.add(id);
        });
      },
      onTap: () {
        if (_selectionMode) {
          setState(() {
            _selectedCameraIds.contains(id)
                ? _selectedCameraIds.remove(id)
                : _selectedCameraIds.add(id);
          });
        }
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/camera_baby.png',
                  width: 64,
                  height: 64,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        camera['cameraName'] ?? '카메라',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ip : $maskedIp',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_selectionMode)
            Positioned(
              right: 30,
              top: 16,
              child: Icon(
                _selectedCameraIds.contains(id)
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color:
                    _selectedCameraIds.contains(id)
                        ? Colors.deepPurple
                        : Colors.grey,
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
        title: const Text('카메라'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "등록된 카메라 📸",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_cameras.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectionMode = !_selectionMode;
                                _selectedCameraIds.clear();
                              });
                            },
                            child: Text(
                              _selectionMode ? '취소' : '편집',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        _cameras.isEmpty
                            ? const Center(child: Text('등록된 카메라가 없습니다.'))
                            : ListView.builder(
                              itemCount: _cameras.length,
                              itemBuilder:
                                  (context, index) =>
                                      _buildCameraCard(_cameras[index], index),
                            ),
                  ),
                ],
              ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child:
              !_selectionMode
                  ? InkWell(
                    onTap: _goToQRPage,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A4DFF),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '카메라 등록!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'QR 코드를 통해 편리하게 카메라를 등록하세요!',
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                  : SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _deleteSelectedCameras,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A4DFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
