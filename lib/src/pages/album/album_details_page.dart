import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

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
      logger.i('[삭제 확인] 이미지 ID ${widget.imageId} 삭제 진행');
      await ApiService.deletePictureById(token: token, imageId: widget.imageId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('사진이 삭제되었습니다')));
      logger.i('[삭제 완료] 이미지 ID ${widget.imageId} 삭제됨');
      Navigator.pop(context, true);
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
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('아니요', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _deleteImage();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 상세'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return SizedBox(
                width: width,
                height: width,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 60,
                        ),
                      ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.black,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      captureTime.isNotEmpty ? captureTime : '날짜 정보 없음',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    logger.i('[삭제 버튼 클릭됨] 이미지 ID: ${widget.imageId}');
                    _confirmDeleteDialog(context);
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.delete_outline, color: Colors.black, size: 24),
                      SizedBox(width: 10),
                      Text('삭제', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
