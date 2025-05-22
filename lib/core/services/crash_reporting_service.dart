// lib/core/services/crash_reporting_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CrashReportingService {
  final Dio _dio;
  
  CrashReportingService(this._dio);
  
  Future<void> recordError(dynamic error, StackTrace stackTrace) async {
    if (kDebugMode) {
      // Just print in debug mode
      debugPrint('ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');
      return;
    }
    
    try {
      // Get device info
      final deviceInfo = await _getDeviceInfo();
      
      // Get app info
      final packageInfo = await PackageInfo.fromPlatform();
      
      // Send error to backend
      await _dio.post(
        '${dotenv.env['API_BASE_URL']}/errors/report/',
        data: {
          'error': error.toString(),
          'stack_trace': stackTrace.toString(),
          'device_info': deviceInfo,
          'app_version': packageInfo.version,
          'build_number': packageInfo.buildNumber,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silently fail for crash reporting
      debugPrint('Failed to report error: $e');
    }
  }
  
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final Map<String, dynamic> deviceInfo = {};
    
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceInfo['platform'] = 'android';
        deviceInfo['model'] = androidInfo.model;
        deviceInfo['manufacturer'] = androidInfo.manufacturer;
        deviceInfo['version'] = androidInfo.version.release;
        deviceInfo['sdk_int'] = androidInfo.version.sdkInt;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceInfo['platform'] = 'ios';
        deviceInfo['model'] = iosInfo.model;
        deviceInfo['version'] = iosInfo.systemVersion;
        deviceInfo['name'] = iosInfo.name;
      }
    } catch (e) {
      deviceInfo['error'] = e.toString();
    }
    
    return deviceInfo;
  }
}