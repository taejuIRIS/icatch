import 'package:flutter/material.dart';

class CameraListTab extends StatelessWidget {
  final List<Map<String, dynamic>> cameraList;
  final Function(Map<String, dynamic>) onCameraSelected;
  final VoidCallback onAddPressed;
  final int? selectedCameraId;

  const CameraListTab({
    super.key,
    required this.cameraList,
    required this.onCameraSelected,
    required this.onAddPressed,
    this.selectedCameraId,
  });

  @override
  Widget build(BuildContext context) {
    final filteredList =
        cameraList.where((camera) {
          return camera['cameraName'] != null &&
              camera['deviceIp'] != null &&
              camera['deviceIp'].toString().trim().isNotEmpty;
        }).toList();

    // ✅ 기본 선택 없을 경우 첫 번째 카메라 자동 선택
    if (filteredList.isNotEmpty && selectedCameraId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onCameraSelected(filteredList[0]);
      });
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            ...filteredList.map((camera) => _buildTab(camera)),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(Map<String, dynamic> camera) {
    final bool isSelected = camera['cameraId'] == selectedCameraId;

    return GestureDetector(
      onTap: () => onCameraSelected(camera),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6A4DFF) : const Color(0xFFE7E7FF),
          borderRadius: BorderRadius.circular(24),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.deepPurple.withAlpha((255 * 0.3).toInt()),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : [],
        ),
        child: Text(
          camera['cameraName'] ?? '카메라',
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF090A0A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
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
    );
  }
}
