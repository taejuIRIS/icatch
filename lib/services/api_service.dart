// ✅ api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String baseUrl = dotenv.env['BASE_URL']!;

  // 회원가입
  static Future<Map<String, dynamic>> register({
    required String email,
    required String nickname,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'userNickname': nickname,
        'password': password,
      }),
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'message': responseBody['message'],
        'data': responseBody['data'],
      };
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? '회원가입 실패',
      };
    }
  }

  // 로그인
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && responseBody['success'] == true) {
      return {
        'success': true,
        'message': responseBody['message'],
        'data': responseBody['data'],
      };
    } else {
      return {'success': false, 'message': responseBody['message'] ?? '로그인 실패'};
    }
  }

  // 카메라 이름 등록 (신규 버전 API)
  static Future<Map<String, dynamic>> createCameraName({
    required int userId,
    required int deviceId,
    required String name,
  }) async {
    final url = Uri.parse('$baseUrl/api/cameras/setup');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'deviceId': deviceId,
        'cameraName': name,
      }),
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    if ((response.statusCode == 200 || response.statusCode == 201)) {
      return {'success': true, 'message': '카메라 등록 성공', 'data': responseBody};
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? '카메라 이름 설정 실패',
      };
    }
  }

  // 대상자 설정
  static Future<Map<String, dynamic>> setTargetType({
    required int userId,
    required int cameraId,
    required String targetType,
  }) async {
    final url = Uri.parse('$baseUrl/api/monitoring/targets/create');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'cameraId': cameraId,
        'targetType': targetType,
      }),
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        responseBody['success'] == true) {
      return {
        'success': true,
        'message': responseBody['message'],
        'data': responseBody['data'],
      };
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? '대상 등록 실패',
      };
    }
  }

  // 위험 구역 설정
  static Future<Map<String, dynamic>> setDangerZones({
    required int cameraId,
    required List<int> zones,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/api/camera/$cameraId/danger-zone');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // ✅ 여기서 토큰 사용
      },
      body: jsonEncode({'zones': zones}),
    );

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return {
      'success': response.statusCode == 200 || response.statusCode == 201,
      'message': decoded['message'],
      'data': decoded['data'],
    };
  }

  // 제스처 등록
  static Future<Map<String, dynamic>> createGestureWithFunction({
    required int userId,
    required int cameraId,
    required String gestureName,
    required String gestureType,
    required String gestureDescription,
    required String gestureImagePath,
    required String selectedFunction,
  }) async {
    final url = Uri.parse('$baseUrl/api/gestures/setup');

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

    final body = {
      'userId': userId,
      'cameraId': cameraId,
      'gestureName': gestureName,
      'gestureType': gestureType,
      'gestureDescription': gestureDescription,
      'gestureImagePath': gestureImagePath,
      'selectedFunction': functionEnumMap[selectedFunction] ?? 'NONE',
      'isEnabled': 'yes',
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        responseBody['success'] == true) {
      return {
        'success': true,
        'message': responseBody['message'],
        'data': responseBody['data'],
      };
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? '제스처 등록 실패',
      };
    }
  }

  //조이스틱
  static Future<void> controlCameraDirection({
    required int cameraId,
    required String direction, // "up", "down", "left", "right", "center"
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/api/cameras/$cameraId/control');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'direction': direction}),
    );

    if (response.statusCode == 200) {
      print('카메라 이동 성공: $direction');
    } else {
      print('카메라 이동 실패: ${response.statusCode} / ${response.body}');
    }
  }

  // api_service.dart
  static Future<Map<String, dynamic>> fetchUserCameras(String token) async {
    final url = Uri.parse('$baseUrl/api/cameras/user');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && responseBody['status'] == 'success') {
      return {
        'success': true,
        'data': responseBody['data'], // List of cameras
      };
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? '카메라 목록 조회 실패',
      };
    }
  }
}
