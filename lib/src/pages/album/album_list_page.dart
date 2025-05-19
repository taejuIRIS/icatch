import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import 'album_details_page.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class AlbumListPage extends StatefulWidget {
  const AlbumListPage({super.key});

  @override
  State<AlbumListPage> createState() => _AlbumListPageState();
}

class _AlbumListPageState extends State<AlbumListPage> {
  List<dynamic> pictures = [];
  Set<int> selectedIds = {};
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadPictures();
  }

  Future<void> _loadPictures() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final userId = prefs.getInt('userId');

    if (token == null || userId == null) return;

    try {
      final result = await ApiService.fetchUserPictures(
        token: token,
        userId: userId,
      );

      setState(() {
        pictures = result;
        if (!isEditMode) selectedIds.clear();
      });
    } catch (e) {
      logger.e('📸 사진 불러오기 실패: $e');
    }
  }

  Future<void> _deleteSelectedPictures() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return;

    for (int id in selectedIds) {
      try {
        await ApiService.deletePictureById(token: token, imageId: id);
        logger.i('✅ 삭제 성공: $id');
      } catch (e) {
        logger.e('❌ 삭제 실패 (imageId: $id): $e');
      }
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${selectedIds.length}개 사진 삭제 완료')));

    setState(() {
      isEditMode = false;
      selectedIds.clear();
    });

    await _loadPictures();
  }

  void _toggleSelectAll() {
    setState(() {
      if (selectedIds.length == pictures.length) {
        selectedIds.clear();
      } else {
        selectedIds = pictures.map<int>((p) => p['imageId'] as int).toSet();
      }
    });
  }

  void _confirmDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('삭제'),
            content: const Text('선택한 사진을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('아니요', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _deleteSelectedPictures();
                },
                child: const Text('예'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('앨범', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          if (pictures.isNotEmpty)
            TextButton(
              onPressed: () {
                if (isEditMode) {
                  _toggleSelectAll();
                } else {
                  setState(() => isEditMode = true);
                }
              },
              child: Text(
                isEditMode ? '전체 선택' : '편집',
                style: const TextStyle(
                  color: Color.fromARGB(255, 166, 166, 166),
                ),
              ),
            ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar:
          isEditMode
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        selectedIds.isNotEmpty
                            ? () => _confirmDeleteDialog(context)
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A4DFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              )
              : null,
      body:
          pictures.isEmpty
              ? const Center(
                child: Text(
                  '이미지가 없습니다!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pictures.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final pic = pictures[index];
                  final rawUrl = pic['imageUrl']?.toString() ?? '';
                  final imageUrl =
                      rawUrl.startsWith('http')
                          ? rawUrl
                          : 'http://ceprj.gachon.ac.kr:60004$rawUrl';
                  final imageId = pic['imageId'];
                  final isSelected = selectedIds.contains(imageId);

                  return GestureDetector(
                    onTap: () {
                      if (isEditMode) {
                        setState(() {
                          isSelected
                              ? selectedIds.remove(imageId)
                              : selectedIds.add(imageId);
                        });
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AlbumDetailPage(imageId: imageId),
                          ),
                        ).then((value) {
                          if (value == true) _loadPictures();
                        });
                      }
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                          ),
                                ),
                              ),
                              if (isSelected)
                                Positioned.fill(
                                  child: Container(
                                    color: const Color(0x553C1AFF),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
