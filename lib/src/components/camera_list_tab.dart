import 'package:flutter/material.dart';

class CameraListTab extends StatelessWidget {
  final List<Map<String, dynamic>> cameraList;
  final Function(Map<String, dynamic>) onCameraSelected;
  final VoidCallback onAddPressed;

  const CameraListTab({
    super.key,
    required this.cameraList,
    required this.onCameraSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            ...cameraList.map((camera) => _buildTab(camera)).toList(),
            GestureDetector(
              onTap: onAddPressed,
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7A5FFF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(Map<String, dynamic> camera) {
    return GestureDetector(
      onTap: () => onCameraSelected(camera),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE7E7FF),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          camera['cameraName'] ?? '카메라',
          style: const TextStyle(
            color: Color(0xFF090A0A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
