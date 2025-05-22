import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_service.dart';

class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  AuthService(this._apiService);
  
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'access_token');
    return token != null;
  }
  
  Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    try {
      return await _apiService.login(phoneNumber, password);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      return await _apiService.register(userData);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }
  
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'access_token');
  }
  
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'access_token', value: token);
  }
  
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    // Implement OTP verification with Django backend
    try {
      await _apiService.requestOtp(phoneNumber);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<bool> confirmOtp(String phoneNumber, String otp) async {
    try {
      final result = await _apiService.verifyOtp(phoneNumber, otp);
      return result['success'] ?? false;
    } catch (e) {
      return false;
    }
  }
}