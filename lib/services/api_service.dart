// ✅ api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart'; // ✅ 추가
import 'package:shared_preferences/shared_preferences.dart';

final Logger logger = Logger(); // ✅ 전역 Logger 인스턴스

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

  //카메라 이름 설정
  static Future<Map<String, dynamic>> createCameraName({
    required int userId,
    required int deviceId,
    required String name,
  }) async {
    final url = Uri.parse('$baseUrl/api/cameras/setup');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'deviceId': deviceId,
          'cameraName': name,
        }),
      );

      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      logger.i('📦 API 응답: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final cameraId = responseBody['data']?['cameraId'];

        if (cameraId != null) {
          return {'success': true, 'cameraId': cameraId};
        } else {
          return {
            'success': false,
            'message': '📛 cameraId 없음: ${responseBody['data']}',
          };
        }
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? '카메라 이름 설정 실패',
        };
      }
    } catch (e) {
      logger.e('❌ 카메라 이름 등록 중 오류: $e');
      return {'success': false, 'message': '예외 발생: $e'};
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
    required String selectedFunction, // ENUM 값 (예: EMERGENCY_TEXT)
    int actionId = 1, // ✅ 기본값 1, 필요 시 전달 가능
  }) async {
    final url = Uri.parse('$baseUrl/api/gestures');

    final body = {
      'userId': userId,
      'cameraId': cameraId,
      'gestureName': gestureName,
      'gestureType': gestureType,
      'gestureDescription': gestureDescription,
      'gestureImagePath': gestureImagePath,
      'selectedFunction': selectedFunction,
      'isEnabled': 'yes',
      'actionId': actionId,
    };

    logger.i('[DEBUG] 등록 요청: $body');

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
      logger.i('카메라 이동 성공: $direction');
    } else {
      logger.i('카메라 이동 실패: ${response.statusCode} / ${response.body}');
    }
  }

  // 사용자 프로필 조회
  static Future<Map<String, dynamic>> fetchUserProfile(String token) async {
    final url = Uri.parse('$baseUrl/api/profile');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 && responseBody['success'] == true) {
      return {'success': true, 'data': responseBody['data']};
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? '프로필 조회 실패',
      };
    }
  }

  // 카메라 개수 조회
  static Future<int> fetchCameraCount(String token) async {
    final url = Uri.parse('$baseUrl/api/profile/cameras/count');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 && responseBody['success'] == true) {
      return responseBody['data']['count'] ?? 0;
    } else {
      return 0;
    }
  }

  // 알림 설정
  static Future<Map<String, dynamic>> updateNotificationSetting({
    required bool enabled,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/api/users/notification');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'enabled': enabled}),
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && responseBody['status'] == 'success') {
      return {'success': true, 'message': responseBody['message']};
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? '알림 설정 실패',
      };
    }
  }

  // 디바이스 정보 조회
  static Future<Map<String, dynamic>?> fetchDeviceInfo(int userId) async {
    final url = Uri.parse(
      '$baseUrl/api/device/auth/authenticate?userId=$userId',
    );

    try {
      final response = await http.get(url);
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      logger.i('✅ 서버 응답: $decoded');

      final data = decoded['data'];

      // 성공 조건 완화
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded['success'] == true &&
          data != null &&
          data['deviceId'] != null &&
          data['cameraId'] != null &&
          data['deviceIP'] != null) {
        return {
          'deviceId': data['deviceId'],
          'deviceIP': data['deviceIP'],
          'cameraId': data['cameraId'],
        };
      } else {
        logger.e('⛔ ❌ 응답은 왔지만 필수 필드 누락 또는 실패: $decoded');
        return null;
      }
    } catch (e) {
      logger.e('❌ 디바이스 정보 요청 중 오류 발생: $e');
      return null;
    }
  }

  // 카메라 전체 목록 조회 (토큰 필요)
  static Future<List<Map<String, dynamic>>> fetchUserCameras2() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/api/cameras/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 && decoded['success'] == true) {
      return List<Map<String, dynamic>>.from(decoded['data']);
    } else {
      throw Exception(decoded['message'] ?? '카메라 조회 실패');
    }
  }

  //카메라 삭제
  static Future<bool> deleteCamera(int cameraId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/api/profile/cameras/$cameraId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  // 제스처 리스트 조회 (userId 기반)
  static Future<List<dynamic>> fetchAllGestures() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final token = prefs.getString('authToken'); // ✅ 토큰 가져오기

      if (userId == null || token == null) {
        logger.e('❌ userId 또는 authToken이 SharedPreferences에 없습니다.');
        return [];
      }

      final url = Uri.parse(
        '$baseUrl/api/gestures/user/$userId/with-actions',
      ); // ✅ 경로 수정
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // ✅ 헤더에 토큰 추가
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonData['data'];
      } else {
        logger.e('❌ 제스처 조회 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      logger.e('❌ 제스처 조회 중 예외 발생: $e');
      return [];
    }
  }

  //제스처 삭제
  static Future<void> deleteGesture(int gestureId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/gestures/$gestureId'),
    );

    if (res.statusCode != 200) {
      throw Exception('제스처 삭제 실패: $gestureId');
    }
  }

  // 비밀 번호 변경
  static Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url = Uri.parse('$baseUrl/api/users/password');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    return {'statusCode': response.statusCode, 'data': responseBody};
  }

  // 회원 탈퇴
  static Future<Map<String, dynamic>> deleteAccount(String token) async {
    final url = Uri.parse('$baseUrl/api/users/me');

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    final result = {
      'success': response.statusCode == 200,
      'statusCode': response.statusCode,
      'body': utf8.decode(response.bodyBytes),
    };

    return result;
  }

  // 카메라 리스트 {홈화면}
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

    // ✅ 'status' → 'success'로 수정
    if (response.statusCode == 200 && responseBody['success'] == true) {
      return {'success': true, 'data': responseBody['data']};
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? '카메라 목록 조회 실패',
      };
    }
  }

  // 타겟 목록
  static Future<int> fetchTargetCount(String token, int userId) async {
    final url = Uri.parse('$baseUrl/api/monitoring/targets/user/$userId');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 && responseBody['success'] == true) {
      final List targets = responseBody['targets'];
      return targets.length;
    } else {
      return 0;
    }
  }

  /// 유저의 사진 목록 조회
  static Future<List<dynamic>> fetchUserPictures({
    required String token,
    required int userId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/monitoring/pictures/list/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['pictures'] ?? [];
    } else {
      throw Exception('사진 불러오기 실패: ${response.body}');
    }
  }

  /// 특정 이미지 정보 조회 (필요 시 추가)
  static Future<Map<String, dynamic>> fetchImageDetail({
    required String token,
    required int imageId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/monitoring/pictures/image/$imageId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('이미지 상세 조회 실패: ${response.body}');
    }
  }

  // 🔥 사진 삭제 API
  static Future<bool> deletePictureById({
    required String token,
    required int imageId,
  }) async {
    final url = Uri.parse('$baseUrl/api/monitoring/pictures/$imageId');

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }

  // 이미지 상세 정보
  static Future<Map<String, dynamic>> fetchPictureDetail({
    required String token,
    required int imageId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/monitoring/pictures/detail/$imageId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data;
    } else {
      throw Exception('이미지 상세 정보 불러오기 실패: ${response.body}');
    }
  }

  // 알림 목록 조회
  static Future<List<dynamic>> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      logger.e('❌ authToken이 없습니다.');
      return [];
    }

    final url = Uri.parse('$baseUrl/api/notifications');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 && responseBody['success'] == true) {
      return responseBody['data']['notifications'];
    } else {
      logger.e(
        '❌ 알림 조회 실패: ${response.statusCode}, ${responseBody['message']}',
      );
      return [];
    }
  }
}
