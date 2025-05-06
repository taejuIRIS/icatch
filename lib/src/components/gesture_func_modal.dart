import 'package:flutter/material.dart';

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
    '신고 기능': 'EMERGENCY_TEXT',
    '사진 찍기': 'TIME_CAPTURE',
    '알림 ON/OFF': 'SIGNAL',
    '“괜찮아~” 알림 보내기': 'PERSON_TEXT',
    '“도와줘!” 알림 보내기': 'HELP_TEXT',
    '“불편해 ㅠㅠ” 알림 보내기': 'BLACK_TEXT',
    '“인사하기👋” 알림 보내기': 'ALARM',
  };

  late String? currentSelection;
  late List<String> functions;

  @override
  void initState() {
    super.initState();
    currentSelection = widget.selectedFunction;
    functions = functionEnumMap.keys.toList();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 위쪽 슬라이더 (모달 닫기용)
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Text(
              '선택하신 제스처로 무슨 기능으로 사용할까요?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF090A0A),
              ),
            ),
            const SizedBox(height: 16),
            ...functions.map(
              (func) => ListTile(
                title: Text(func, style: const TextStyle(fontSize: 15)),
                trailing:
                    currentSelection == func
                        ? const Icon(Icons.check, color: Color(0xFF6A4DFF))
                        : null,
                onTap: () {
                  setState(() {
                    currentSelection = func;
                  });
                  // 선택 후 150ms 뒤에 닫기 (애니메이션 자연스럽게)
                  Future.delayed(const Duration(milliseconds: 150), () {
                    Navigator.of(context).pop(func);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
