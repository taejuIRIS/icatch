import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GestureListPage extends StatefulWidget {
  const GestureListPage({super.key});

  @override
  State<GestureListPage> createState() => _GestureListPageState();
}

class _GestureListPageState extends State<GestureListPage> {
  List<dynamic> _gestures = [];

  @override
  void initState() {
    super.initState();
    _fetchGestures();
  }

  Future<void> _fetchGestures() async {
    final response = await http.get(
      Uri.parse('http://ceprj.gachon.ac.kr:60004/api/gestures'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(
        utf8.decode(response.bodyBytes),
      );
      setState(() {
        _gestures = jsonData['data'];
      });
    } else {
      print("Failed to load gestures");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('등록된 제스처 👋'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body:
          _gestures.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _gestures.length,
                itemBuilder: (context, index) {
                  final gesture = _gestures[index];
                  final imagePath =
                      gesture['gestureImagePath'].toString().startsWith('http')
                          ? gesture['gestureImagePath']
                          : 'http://ceprj.gachon.ac.kr:60004${gesture['gestureImagePath']}';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Image.network(
                          imagePath,
                          width: 64,
                          height: 64,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.image),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '제스처 이름: ${gesture['gestureName']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('기능 설명: ${gesture['gestureDescription']}'),
                              Text('카메라 ID: ${gesture['cameraId']}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/settingsGesture');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A4DFF),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: const Text(
            '제스처 등록!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
