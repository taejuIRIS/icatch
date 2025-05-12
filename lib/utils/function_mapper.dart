String getFunctionDescription(String code) {
  const map = {
    'BLACK_SCREEN': '블랙 스크린 ON/OFF',
    'SIGNAL': '알림 ON/OFF',
    'TIME_CAPTURE': '사진 찍기',
    'ALARM': '“인사하기👋” 알림 보내기',
    'FINE_TEXT': '“괜찮아~” 알림 보내기',
    'EMERGENCY_TEXT': '“도와줘!” 알림 보내기',
    'HELP_TEXT': '“불편해 ㅠㅠ” 알림 보내기',
    'PERSON_TEXT': '“인사하기😊” 알림 보내기',
  };

  return map[code] ?? '기능 없음';
}
