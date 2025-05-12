import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';

class AlbumDetailPage extends StatefulWidget {
  final int imageId;

  const AlbumDetailPage({super.key, required this.imageId});

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  Map<String, dynamic>? picture;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPictureDetail();
  }

  Future<void> _loadPictureDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('토큰이 존재하지 않습니다')));
      return;
    }

    try {
      final detail = await ApiService.fetchPictureDetail(
        token: token,
        imageId: widget.imageId,
      );
      setState(() {
        picture = detail;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('상세 정보 불러오기 실패: $e')));
    }
  }

  Future<void> _deleteImage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('토큰이 존재하지 않습니다')));
      return;
    }

    try {
      await ApiService.deletePictureById(token: token, imageId: widget.imageId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('사진이 삭제되었습니다')));
      Navigator.pop(context, true); // 이전 페이지에 true 반환
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
    }
  }

  void _confirmDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('삭제'),
            content: const Text('정말로 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(), // 닫기
                child: const Text('아니요', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // 다이얼로그 닫고
                  _deleteImage(); // 실제 삭제 실행
                },
                child: const Text('예'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || picture == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final imageUrl = 'http://ceprj.gachon.ac.kr:60004${picture!['imageUrl']}';
    final captureTime = picture!['formattedCaptureTime'] ?? '';
    final deviceName = picture!['deviceName'] ?? '알 수 없음';

    return Scaffold(
      appBar: AppBar(title: const Text('사진 상세'), centerTitle: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                captureTime,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '📷 기기명: $deviceName',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          // 삭제 아이콘과 텍스트만 남겨둠
          IconButton(
            onPressed: () => _confirmDeleteDialog(context),
            icon: const Icon(Icons.delete_outline, size: 28),
          ),
          const Text('삭제'),
        ],
      ),
    );
  }
}
