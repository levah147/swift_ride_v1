import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/logger.dart';
import '../models/ride_model.dart';

class RideRepository {
  final ApiClient _apiClient;

  RideRepository(this._apiClient);

  // Request a new ride
  Future<Map<String, dynamic>> requestRide({
    required String categoryId,
    String? paymentMethodId,
    required double pickupLatitude,
    required double pickupLongitude,
    required String pickupAddress,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationAddress,
    required double estimatedDistanceKm,
    required int estimatedDurationMinutes,
  }) async {
    try {
      final data = {
        'category_id': categoryId,
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'pickup_address': pickupAddress,
        'destination_latitude': destinationLatitude,
        'destination_longitude': destinationLongitude,
        'destination_address': destinationAddress,
        'estimated_distance_km': estimatedDistanceKm,
        'estimated_duration_minutes': estimatedDurationMinutes,
      };
      
      if (paymentMethodId != null) {
        data['payment_method_id'] = paymentMethodId;
      }

      final response = await _apiClient.post(
        ApiConstants.rides,
        data: data,
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'ride': RideModel.fromJson(response.data['data']),
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to request ride',
        'errors': response.data['errors'],
      };
    } on DioException catch (e) {
      AppLogger.error('Request ride error', e);
      return _handleDioError(e, 'Failed to request ride');
    } catch (e) {
      AppLogger.error('Unexpected request ride error', e);
      return {
        'success': false,
        'message': 'An unexpected error occurred while requesting ride',
      };
    }
  }

  // Get active ride
  Future<Map<String, dynamic>> getActiveRide() async {
    try {
      final response = await _apiClient.get(ApiConstants.activeRide);

      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          return {
            'success': true,
            'ride': null,
            'message': 'No active ride found',
          };
        }
        
        return {
          'success': true,
          'ride': RideModel.fromJson(response.data['data']),
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get active ride',
      };
    } on DioException catch (e) {
      AppLogger.error('Get active ride error', e);
      return _handleDioError(e, 'Failed to get active ride');
    } catch (e) {
      AppLogger.error('Unexpected get active ride error', e);
      return {
        'success': false,
        'message': 'An unexpected error occurred while getting active ride',
      };
    }
  }

  // Get ride history
  Future<Map<String, dynamic>> getRideHistory({
    String? status,
    String? dateFrom,
    String? dateTo,
    int page = 1,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
      };
      
      if (status != null) queryParams['status'] = status;
      if (dateFrom != null) queryParams['date_from'] = dateFrom;
      if (dateTo != null) queryParams['date_to'] = dateTo;

      final response = await _apiClient.get(
        ApiConstants.rideHistory,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final rides = (response.data['data'] as List)
            .map((x) => RideModel.fromJson(x))
            .toList();
            
        return {
          'success': true,
          'rides': rides,
          'message': response.data['message'],
          'next': response.data['next'],
          'previous': response.data['previous'],
          'count': response.data['count'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get ride history',
      };
    } on DioException catch (e) {
      AppLogger.error('Get ride history error', e);
      return _handleDioError(e, 'Failed to get ride history');
    } catch (e) {
      AppLogger.error('Unexpected get ride history error', e);
      return {
        'success': false,
        'message': 'An unexpected error occurred while getting ride history',
      };
    }
  }

  // Get ride details
  Future<Map<String, dynamic>> getRideDetails(String rideId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.rides}$rideId/');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'ride': RideModel.fromJson(response.data['data']),
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get ride details',
      };
    } on DioException catch (e) {
      AppLogger.error('Get ride details error', e);
      return _handleDioError(e, 'Failed to get ride details');
    } catch (e) {
      AppLogger.error('Unexpected get ride details error', e);
      return {
        'success': false,
        'message': 'An unexpected error occurred while getting ride details',
      };
    }
  }

  // Cancel ride
  Future<Map<String, dynamic>> cancelRide(String rideId, {String? reason}) async {
    try {
      final data = reason != null ? {'reason': reason} : null;
      
      final response = await _apiClient.post(
        '${ApiConstants.rides}$rideId/cancel/',
        data: data,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'ride': RideModel.fromJson(response.data['data']),
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to cancel ride',
        'errors': response.data['errors'],
      };
    } on DioException catch (e) {
      AppLogger.error('Cancel ride error', e);
      return _handleDioError(e, 'Failed to cancel ride');
    } catch (e) {
      AppLogger.error('Unexpected cancel ride error', e);
      return {
        'success': false,
        'message': 'An unexpected error occurred while cancelling ride',
      };
    }
  }

  // Rate ride
  Future<Map<String, dynamic>> rateRide(
    String rideId, {
    required int rating,
    String? feedback,
  }) async {
    try {
      final data = {
        'user_rating': rating,
      };
      
      if (feedback != null) {
        data['user_feedback'] = feedback as int;
      }

      final response = await _apiClient.post(
        '${ApiConstants.rides}$rideId/rate_ride/',
        data: data,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'ride': RideModel.fromJson(response.data['data']),
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to rate ride',
        'errors': response.data['errors'],
      };
    } on DioException catch (e) {
      AppLogger.error('Rate ride error', e);
      return _handleDioError(e, 'Failed to rate ride');
    } catch (e) {
      AppLogger.error('Unexpected rate ride error', e);
      return {
        'success': false,
        'message': 'An unexpected error occurred while rating ride',
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

// Provider for RideRepository
final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return RideRepository(getIt<ApiClient>());
});
