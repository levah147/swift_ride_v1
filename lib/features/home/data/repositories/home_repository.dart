import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/logger.dart';
import '../models/home_data_model.dart';

class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository(this._apiClient);

  // Get home page data
  Future<Map<String, dynamic>> getHomeData() async {
    try {
      final response = await _apiClient.get(ApiConstants.homeData);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': HomeDataModel.fromJson(response.data['data']),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get home data',
      };
    } on DioException catch (e) {
      AppLogger.error('Get home data error', e);
      return _handleDioError(e, 'Failed to get home data');
    } catch (e) {
      AppLogger.error('Unexpected get home data error', e);
      return {
        'success': false,
        'message': 'An unexpected error occurred while getting home data',
      };
    }
  }

  // Get ride categories
  Future<Map<String, dynamic>> getRideCategories() async {
    try {
      final response = await _apiClient.get(ApiConstants.categories);

      if (response.statusCode == 200) {
        final categories = (response.data['data'] as List)
            .map((x) => RideCategoryModel.fromJson(x))
            .toList();
        return {
          'success': true,
          'categories': categories,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get ride categories',
      };
    } on DioException catch (e) {
      AppLogger.error('Get ride categories error', e);
      return _handleDioError(e, 'Failed to get ride categories');
    } catch (e) {
      AppLogger.error('Unexpected get ride categories error', e);
      return {
        'success': false,
        'message': 'An unexpected error occurred while getting ride categories',
      };
    }
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

// Provider for HomeRepository
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(getIt<ApiClient>());
});
