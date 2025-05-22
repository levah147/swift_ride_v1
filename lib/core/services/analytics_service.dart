// lib/core/services/analytics_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AnalyticsService {
  final Dio _dio;
  
  AnalyticsService(this._dio);
  
  Future<void> logEvent(String eventName, Map<String, dynamic> parameters) async {
    try {
      await _dio.post(
        '${dotenv.env['API_BASE_URL']}/analytics/events/',
        data: {
          'event_name': eventName,
          'parameters': parameters,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silently fail for analytics
      print('Analytics error: $e');
    }
  }
  
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    try {
      await _dio.post(
        '${dotenv.env['API_BASE_URL']}/analytics/user-properties/',
        data: properties,
      );
    } catch (e) {
      // Silently fail for analytics
      print('Analytics error: $e');
    }
  }
  
  Future<void> logScreenView(String screenName) async {
    await logEvent('screen_view', {'screen_name': screenName});
  }
}