import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class GestureFuncModal extends StatefulWidget {
  final String? selectedFunction;
  final Function(String) onSelect;

  const GestureFuncModal({
    super.key,
    required this.selectedFunction,
    required this.onSelect,
  });

  @override
  State<GestureFuncModal> createState() => _GestureFuncModalState();
}

class _GestureFuncModalState extends State<GestureFuncModal> {
  final Map<String, String> functionEnumMap = {
    '블랙 스크린 ON/OFF': 'BLACK_SCREEN',
    '신고 기능': 'SIGNAL',
    '사진 찍기': 'TIME_CAPTURE',
    '“인사하기👋” 알림 보내기': 'ALARM',
    '“괜찮아~” 알림 보내기': 'FINE_TEXT',
    '“도와줘!” 알림 보내기': 'EMERGENCY_TEXT',
    '“불편해 ㅠㅠ” 알림 보내기': 'HELP_TEXT',
  };

  late String? currentSelection;

  @override
  void initState() {
    super.initState();
    currentSelection = widget.selectedFunction;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              functionEnumMap.entries.map((entry) {
                final name = entry.key;
                final code = entry.value;
                return ListTile(
                  title: Text(name),
                  trailing:
                      currentSelection == code
                          ? const Icon(Icons.check, color: Colors.deepPurple)
                          : null,
                  onTap: () {
                    logger.i('✅ [Modal] 선택됨: $code');
                    Navigator.of(context).pop(code); // ✅ 기능 코드 반환
                  },
                );
              }).toList(),
        ),
      ),
    );
  }
}
