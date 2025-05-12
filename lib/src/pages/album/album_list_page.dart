import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import 'album_details_page.dart';

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
      });
    } catch (e) {
      logger.i('사진 불러오기 실패: $e');
    }
  }

  Future<void> _deleteSelectedPictures() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return;

    for (int id in selectedIds) {
      await ApiService.deletePictureById(token: token, imageId: id);
    }

    setState(() {
      isEditMode = false;
      selectedIds.clear();
    });

    _loadPictures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('앨범', style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => isEditMode = !isEditMode);
            },
            child: Text(
              isEditMode ? '전체 선택' : '편집',
              style: const TextStyle(color: Color.fromARGB(255, 166, 166, 166)),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      bottomNavigationBar:
          isEditMode && selectedIds.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _deleteSelectedPictures,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A5FFF),
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
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final pic = pictures[index];
                  final imageUrl =
                      'http://ceprj.gachon.ac.kr:60004${pic['imageUrl']}';
                  final captureTime = pic['formattedCaptureTime'] ?? '';
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
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                  if (isSelected)
                                    Container(color: const Color(0x997A5FFF)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              captureTime,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        if (isEditMode)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color:
                                  isSelected ? Colors.deepPurple : Colors.grey,
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
