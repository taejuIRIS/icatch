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
  List<dynamic> pictures = [];
  int currentIndex = 0;
  bool isLoading = true;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _loadPictures();
  }

  // Future<void> _loadPictures() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('authToken');
  //   final userId = prefs.getInt('userId');

  //   if (token == null || userId == null) return;

  //   try {
  //     final fetched = await ApiService.fetchUserPictures(
  //       token: token,
  //       userId: userId,
  //     );

  //     final idx = fetched.indexWhere((p) => p['imageId'] == widget.imageId);
  //     setState(() {
  //       pictures = fetched;
  //       currentIndex = idx != -1 ? idx : 0;
  //       _pageController = PageController(initialPage: currentIndex);
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     logger.e('사진 목록 로딩 실패: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
  //   }
  // }
  Future<void> _loadPictures() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final userId = prefs.getInt('userId');

    if (token == null || userId == null) return;

    try {
      final fetched = await ApiService.fetchUserPictures(
        token: token,
        userId: userId,
      );

      // ✅ imagePath 기준 중복 제거 - 첫 항목만 남김
      final seenPaths = <String>{};
      final deduplicated = <Map<String, dynamic>>[];

      for (var pic in fetched) {
        final path = pic['imagePath'];
        if (!seenPaths.contains(path)) {
          seenPaths.add(path);
          deduplicated.add(pic);
        }
      }

      // ✅ 전달받은 imageId의 위치 찾기 (중복 제거된 리스트 기준)
      final idx = deduplicated.indexWhere(
        (p) => p['imageId'] == widget.imageId,
      );

      setState(() {
        pictures = deduplicated;
        currentIndex = idx != -1 ? idx : 0;
        _pageController = PageController(initialPage: currentIndex);
        isLoading = false;
      });
    } catch (e) {
      logger.e('사진 목록 로딩 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _confirmDeleteDialog(int imageId) {
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
                  _deleteImage(imageId);
                },
                child: const Text('예'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteImage(int imageId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return;

    try {
      await ApiService.deletePictureById(token: token, imageId: imageId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('사진이 삭제되었습니다')));

      setState(() {
        pictures.removeWhere((p) => p['imageId'] == imageId);
        if (pictures.isEmpty) {
          Navigator.pop(context);
        } else {
          currentIndex = currentIndex.clamp(0, pictures.length - 1);
          _pageController?.jumpToPage(currentIndex);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || _pageController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 상세'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: pictures.length,
        onPageChanged: (index) => setState(() => currentIndex = index),
        itemBuilder: (context, index) {
          final picture = pictures[index];
          final imageUrl =
              'http://ceprj.gachon.ac.kr:60004${picture['imageUrl']}';
          final captureTime = picture['formattedCaptureTime'] ?? '';
          final deviceId = picture['deviceId']?.toString() ?? '정보 없음';

          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width, // ✅ 1:1 비율
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image, size: 60),
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 22),
                            const SizedBox(width: 14),
                            Text(
                              captureTime.isNotEmpty ? captureTime : '날짜 정보 없음',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.videocam_outlined, size: 22),
                            const SizedBox(width: 14),
                            Text(
                              '디바이스 ID: $deviceId',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => _confirmDeleteDialog(picture['imageId']),
                          child: Row(
                            children: const [
                              Icon(Icons.delete_outline, size: 24),
                              SizedBox(width: 10),
                              Text('삭제', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              if (index > 0)
                Positioned(
                  left: 1,
                  top:
                      MediaQuery.of(context).size.width / 2 -
                      24, // 48 아이콘 사이즈 기준 중앙 정렬
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, size: 48),
                    onPressed:
                        () => _pageController?.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                  ),
                ),
              if (index < pictures.length - 1)
                Positioned(
                  right: 1,
                  top:
                      MediaQuery.of(context).size.width / 2 -
                      24, // 48 아이콘 사이즈 기준 중앙 정렬
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right, size: 48),
                    onPressed:
                        () => _pageController?.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
