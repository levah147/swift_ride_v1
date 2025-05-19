import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../network/api_client.dart';
import '../storage/local_storage_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External services
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Core services
  getIt.registerSingleton<LocalStorageService>(
    LocalStorageService(sharedPreferences),
  );

  // Network
  getIt.registerSingleton<Dio>(_configureDio());
  getIt.registerSingleton<ApiClient>(ApiClient(getIt<Dio>()));
}

Dio _configureDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: dotenv.get('API_BASE_URL', fallback: ApiConstants.baseUrl),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add logger in debug mode
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
    ),
  );

  return dio;
}
