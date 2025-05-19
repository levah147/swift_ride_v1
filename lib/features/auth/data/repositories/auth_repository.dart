
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  // Register a new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String phoneNumber,
    required String fullName,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'email': email,
          'phone_number': phoneNumber,
          'full_name': fullName,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      if (response.statusCode == 201) {
        // Save tokens
        final tokens = response.data['data']['tokens'];
        await _apiClient.saveTokens(tokens['access'], tokens['refresh']);
        
        // Parse and return user data
        final userData = response.data['data']['user'];
        return {
          'success': true,
          'user': UserModel.fromJson(userData),
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Registration failed',
        'errors': response.data['errors'],
      };
    } on DioException catch (e) {
      AppLogger.error('Registration error', e);
      return _handleDioError(e, 'Registration failed');
    } catch (e) {
      AppLogger.error('Unexpected registration error', e);
      return {
        'success': false,
        'message': 'An unexpected error occurred during registration',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    try {
      final data = {
        'password': password,
      };
      
      if (email != null) {
        data['email'] = email;
      } else if (phoneNumber != null) {
        data['phone_number'] = phoneNumber;
      } else {
        return {
          'success': false,
          'message': 'Either email or phone number is required',
        };
      }

      final response = await _apiClient.post(
        ApiConstants.login,
        data: data,
      );

      if (response.statusCode == 200) {
        // Save tokens
        final tokens = response.data['data']['tokens'];
        await _apiClient.saveTokens(tokens['access'], tokens['refresh']);
        
        // Parse and return user data
        final userData = response.data['data']['user'];
        return {
          'success': true,
          'user': UserModel.fromJson(userData),
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Login failed',
        'errors': response.data['errors'],
      };
    } on DioException catch (e) {
      AppLogger.error('Login error', e);
      return _handleDioError(e, 'Login failed');
    } catch (e) {
      AppLogger.error('Unexpected login error', e);
      return {
        'success': false,
        'message': 'An unexpected error occurred during login',
      };
    }
  }

  // Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      final refreshToken = await _apiClient.getRefreshToken();
      
      final response = await _apiClient.post(
        ApiConstants.logout,
        data: {'refresh_token': refreshToken},
      );

      // Clear tokens regardless of response
      await _apiClient.clearTokens();

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Logout successful',
        };
      }

      return {
        'success': true, // Still consider it successful since tokens are cleared
        'message': 'Logged out',
      };
    } catch (e) {
      AppLogger.error('Logout error', e);
      // Still clear tokens on error
      await _apiClient.clearTokens();
      return {
        'success': true, // Still consider it successful since tokens are cleared
        'message': 'Logged out',
      };
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': UserModel.fromJson(response.data['data']),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get user profile',
      };
    } on DioException catch (e) {
      AppLogger.error('Get profile error', e);
      return _handleDioError(e, 'Failed to get user profile');
    } catch (e) {
      AppLogger.error('Unexpected get profile error', e);
      return {
        'success': false,
        'message': 'An unexpected error occurred while getting user profile',
      };
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final data = {};
      if (fullName != null) data['full_name'] = fullName;
      if (email != null) data['email'] = email;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;

      final response = await _apiClient.put(
        ApiConstants.profile,
        data: data,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': UserModel.fromJson(response.data['data']),
          'message': 'Profile updated successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update profile',
        'errors': response.data['errors'],
      };
    } on DioException catch (e) {
      AppLogger.error('Update profile error', e);
      return _handleDioError(e, 'Failed to update profile');
    } catch (e) {
      AppLogger.error('Unexpected update profile error', e);
      return {
        'success': false,
        'message': 'An unexpected error occurred while updating profile',
      };
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.changePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Password changed successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to change password',
        'errors': response.data['errors'],
      };
    } on DioException catch (e) {
      AppLogger.error('Change password error', e);
      return _handleDioError(e, 'Failed to change password');
    } catch (e) {
      AppLogger.error('Unexpected change password error', e);
      return {
        'success': false,
        'message': 'An unexpected error occurred while changing password',
      };
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _apiClient.hasValidToken();
  }

  // Helper method to handle Dio errors
  Map<String, dynamic> _handleDioError(DioException e, String defaultMessage) {
    if (e.response != null) {
      try {
        final responseData = e.response!.data;
        return {
          'success': false,
          'message': responseData['message'] ?? defaultMessage,
          'errors': responseData['errors'],
        };
      } catch (_) {
        return {
          'success': false,
          'message': defaultMessage,
        };
      }
    }
    
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return {
        'success': false,
        'message': 'Connection timeout. Please check your internet connection.',
      };
    }
    
    if (e.type == DioExceptionType.connectionError) {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network settings.',
      };
    }
    
    return {
      'success': false,
      'message': defaultMessage,
    };
  }
}

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(getIt<ApiClient>());
});
