import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../services/api_service.dart';

class TargetListPage extends StatefulWidget {
  const TargetListPage({super.key});

  @override
  State<TargetListPage> createState() => _TargetListPageState();
}

class _TargetListPageState extends State<TargetListPage> {
  List<dynamic> _targets = [];
  final Set<int> _selectedTargetIds = {};
  bool _selectionMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTargets();
  }

  Future<void> _loadTargets() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final token = prefs.getString('authToken');
    if (userId == null || token == null) return;

    final url = Uri.parse(
      '${ApiService.baseUrl}/api/monitoring/targets/user/$userId',
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _targets = jsonData['targets'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  List<String> _getEmoji(String type) {
    if (type == 'pet') {
      return ['🐶', '🐱']..shuffle();
    } else {
      return ['👦🏻', '👧🏻']..shuffle();
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('삭제 확인'),
            content: const Text('선택한 주거인을 삭제하시겠습니까?'),
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) return;

      for (final id in _selectedTargetIds) {
        final deleteUrl = Uri.parse(
          '${ApiService.baseUrl}/api/monitoring/targets/$id',
        );
        await http.delete(
          deleteUrl,
          headers: {'Authorization': 'Bearer $token'},
        );
      }

      setState(() {
        _selectionMode = false;
        _selectedTargetIds.clear();
      });

      _loadTargets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('주거인'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
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
                          '우리 집 귀염둥이 🐾',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_targets.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectionMode = !_selectionMode;
                                _selectedTargetIds.clear();
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
                        _targets.isEmpty
                            ? const Center(child: Text('등록된 주거인이 없습니다.'))
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _targets.length,
                              itemBuilder: (context, index) {
                                final target = _targets[index];
                                final id = target['targetId'];
                                final type = target['targetType'];
                                final emoji = _getEmoji(type).first;

                                return GestureDetector(
                                  onLongPress: () {
                                    setState(() {
                                      _selectionMode = true;
                                      _selectedTargetIds.add(id);
                                    });
                                  },
                                  onTap: () {
                                    if (_selectionMode) {
                                      setState(() {
                                        _selectedTargetIds.contains(id)
                                            ? _selectedTargetIds.remove(id)
                                            : _selectedTargetIds.add(id);
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.1,
                                              ), // 밝은 그림자 색상
                                              blurRadius: 6, // 퍼짐 정도
                                              offset: Offset(
                                                0,
                                                2,
                                              ), // y축 살짝 아래로 그림자
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              emoji,
                                              style: const TextStyle(
                                                fontSize: 64,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  type == 'pet' ? '반려동물' : '사람',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF090A0A),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  type == 'pet'
                                                      ? '반려동물'
                                                      : '주거인',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF6C7072),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_selectionMode)
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: Icon(
                                            _selectedTargetIds.contains(id)
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            color:
                                                _selectedTargetIds.contains(id)
                                                    ? Colors.deepPurple
                                                    : Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),
                  if (_selectionMode)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _confirmDelete,
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
      bottomSheet:
          !_selectionMode
              ? Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: InkWell(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final cameraId = prefs.getInt('cameraId');
                    final deviceId = prefs.getInt('deviceId');
                    final deviceIP = prefs.getString('deviceIP');

                    if (cameraId == null ||
                        deviceId == null ||
                        deviceIP == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('기기 정보가 없습니다.')),
                      );
                      return;
                    }

                    final result = await Navigator.pushNamed(
                      context,
                      '/targetsAddPage',
                      arguments: {
                        'cameraId': cameraId,
                        'deviceId': deviceId,
                        'deviceIP': deviceIP,
                      },
                    );

                    if (result != null && result is Map<String, dynamic>) {
                      debugPrint('✅ 주거인 등록됨: ${result['targetType']}');
                      _loadTargets(); // 등록 후 목록 갱신
                    }
                  },
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
                          '주거인 등록!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '우리 집에 사는 주거인을 추가해 안전관리를 하세요!',
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
