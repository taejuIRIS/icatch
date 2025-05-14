// add_page.dart
import 'package:flutter/material.dart';
import '../navbar/bottom_navbar.dart';
import '../../services/api_service.dart';
import '../../utils/shared_pref_helper.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();
String getFunctionDescription(String code) {
  const map = {
    'BLACK_SCREEN': '블랙 스크린 ON/OFF',
    'SIGNAL': '신고 기능',
    'TIME_CAPTURE': '사진 찍기',
    'ALARM': '“인사하기👋” 알림 보내기',
    'FINE_TEXT': '“괜찮아~” 알림 보내기',
    'EMERGENCY_TEXT': '“도와줘!” 알림 보내기',
    'HELP_TEXT': '“불편해 ㅠㅠ” 알림 보내기',
  };
  return map[code.trim()] ?? '기능 없음'; // trim()으로 공백 방지
}

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final int _selectedIndex = 1;
  List<dynamic> _gestures = [];
  final Set<int> _selectedGestureIds = {};
  bool _selectionMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGestures();
  }

  Future<void> _loadGestures() async {
    setState(() {
      _gestures = [];
      _isLoading = true;
    });
    final gestures = await ApiService.fetchAllGestures();
    setState(() {
      _gestures = gestures;
      _isLoading = false;
    });
  }

  Future<void> _deleteSelectedGestures() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('삭제 확인'),
            content: const Text('선택한 제스처를 삭제하시겠습니까?'),
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
      for (final id in _selectedGestureIds) {
        await ApiService.deleteGesture(id);
      }
      setState(() {
        _selectionMode = false;
        _selectedGestureIds.clear();
      });
      _loadGestures();
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/AddPage');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/NotificationPage');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/PersonalPage');
        break;
    }
  }

  Future<void> _navigateToGestureAddPage() async {
    final cameraId = await SharedPrefHelper.getCameraId() ?? 1;
    final deviceId = await SharedPrefHelper.getDeviceId() ?? 1;
    final deviceIP = await SharedPrefHelper.getDeviceIP() ?? '192.168.0.100';

    final result = await Navigator.pushNamed(
      context,
      '/GestureAddPage',
      arguments: {
        'cameraId': cameraId,
        'deviceId': deviceId,
        'deviceIP': deviceIP,
      },
    );

    if (result == true) {
      await _loadGestures();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'i',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              TextSpan(
                text: 'Catch',
                style: TextStyle(
                  color: Color(0xFF6A4DFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '등록된 제스처 👋',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_gestures.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectionMode = !_selectionMode;
                                _selectedGestureIds.clear();
                              });
                            },
                            child: Text(
                              _selectionMode ? '전체 선택' : '편집',
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
                        _gestures.isEmpty
                            ? const Center(child: Text('등록된 제스처가 없습니다.'))
                            : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: _gestures.length,
                              itemBuilder: (context, index) {
                                final gesture = _gestures[index];
                                final id = gesture['gestureId'];
                                final imagePath =
                                    gesture['gestureImagePath'].toString();
                                final isNetworkImage = imagePath.startsWith(
                                  'http',
                                );
                                final isAssetImage = imagePath.startsWith(
                                  'assets/',
                                );
                                final imageWidget =
                                    isNetworkImage
                                        ? Image.network(
                                          imagePath,
                                          width: 64,
                                          height: 64,
                                        )
                                        : isAssetImage
                                        ? Image.asset(
                                          imagePath,
                                          width: 64,
                                          height: 64,
                                        )
                                        : const Icon(Icons.image_not_supported);

                                return FutureBuilder<String?>(
                                  future:
                                      SharedPrefHelper.getFunctionForGesture(
                                        id,
                                      ),
                                  builder: (context, snapshot) {
                                    final rawFunction =
                                        snapshot.data ??
                                        gesture['selectedFunction']?.toString();
                                    final functionName = getFunctionDescription(
                                      rawFunction ?? '',
                                    );
                                    logger.i('👉 제스처 $id 기능 코드: $rawFunction');

                                    return GestureDetector(
                                      onLongPress: () {
                                        setState(() {
                                          _selectionMode = true;
                                          _selectedGestureIds.add(id);
                                        });
                                      },
                                      onTap: () {
                                        if (_selectionMode) {
                                          setState(() {
                                            _selectedGestureIds.contains(id)
                                                ? _selectedGestureIds.remove(id)
                                                : _selectedGestureIds.add(id);
                                          });
                                        }
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                imageWidget,
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '제스처 ${index + 1}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        functionName,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                              right: 8,
                                              top: 8,
                                              child: Icon(
                                                _selectedGestureIds.contains(id)
                                                    ? Icons.check_circle
                                                    : Icons
                                                        .radio_button_unchecked,
                                                color:
                                                    _selectedGestureIds
                                                            .contains(id)
                                                        ? Colors.deepPurple
                                                        : Colors.grey,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                  ),
                  if (_selectionMode)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _deleteSelectedGestures,
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
                ],
              ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      bottomSheet:
          !_selectionMode
              ? Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: InkWell(
                  onTap: _navigateToGestureAddPage,
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
                          '제스처 등록!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '제스처를 추가해 편의 기능을 늘려보세요!',
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : null,
    );
  }
}
