// lib/utils/shared_pref_helper.dart

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  // 🔐 userId 저장
  static Future<void> setUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', id);
  }

  // 🔍 userId 불러오기
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // 🔐 토큰 저장
  static Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  // 🔍 토큰 불러오기
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // ❌ 전체 삭제
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') != null;
  }

  static Future<void> setDeviceInfo({
    required int cameraId,
    required int deviceId,
    required String deviceIP,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cameraId', cameraId);
    await prefs.setInt('deviceId', deviceId);
    await prefs.setString('deviceIP', deviceIP);
    await prefs.setBool('isSetupComplete', true); // 로그인에서 체크용
  }

  static Future<int?> getCameraId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('cameraId');
  }

  static Future<int?> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('deviceId');
  }

  static Future<String?> getDeviceIP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('deviceIP');
  }

  static Future<void> saveFunctionForGesture(int gestureId, String func) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gesture_func_$gestureId', func);
  }

  static Future<String?> getFunctionForGesture(int gestureId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gesture_func_$gestureId');
  }
}
