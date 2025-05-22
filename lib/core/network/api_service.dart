import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  ApiService() {
    _dio.options.baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }
  
  // Auth methods
  Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    try {
      final response = await _dio.post('/auth/token/', data: {
        'phone_number': phoneNumber,
        'password': password,
      });
      
      final accessToken = response.data['access'];
      final refreshToken = response.data['refresh'];
      
      await _secureStorage.write(key: 'access_token', value: accessToken);
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/users/', data: userData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }
  
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me/');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.patch('/users/me/', data: userData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  // Add methods for OTP verification
  Future<Map<String, dynamic>> requestOtp(String phoneNumber) async {
    try {
      final response = await _dio.post('/auth/request-otp/', data: {
        'phone_number': phoneNumber,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _dio.post('/auth/verify-otp/', data: {
        'phone_number': phoneNumber,
        'otp': otp,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}


// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class ApiService {
//   final Dio _dio = Dio();
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
//   ApiService() {
//     _dio.options.baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';
//     _dio.options.connectTimeout = const Duration(seconds: 30);
//     _dio.options.receiveTimeout = const Duration(seconds: 30);
//     _dio.options.headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };
    
//     // Add logging interceptor
//     _dio.interceptors.add(PrettyDioLogger(
//       requestHeader: true,
//       requestBody: true,
//       responseHeader: true,
//     ));
    
//     // Add auth interceptor
//     _dio.interceptors.add(InterceptorsWrapper(
//       onRequest: (options, handler) async {
//         final token = await _secureStorage.read(key: 'access_token');
//         if (token != null) {
//           options.headers['Authorization'] = 'Bearer $token';
//         }
//         return handler.next(options);
//       },
//       onError: (DioException error, handler) async {
//         if (error.response?.statusCode == 401) {
//           // Try to refresh token
//           final refreshToken = await _secureStorage.read(key: 'refresh_token');
//           if (refreshToken != null) {
//             try {
//               final response = await _dio.post(
//                 '/auth/token/refresh/',
//                 data: {'refresh': refreshToken},
//               );
              
//               final newToken = response.data['access'];
//               await _secureStorage.write(key: 'access_token', value: newToken);
              
//               // Retry the original request
//               final opts = Options(
//                 method: error.requestOptions.method,
//                 headers: error.requestOptions.headers,
//               );
//               opts.headers?['Authorization'] = 'Bearer $newToken';
              
//               final cloneReq = await _dio.request(
//                 error.requestOptions.path,
//                 options: opts,
//                 data: error.requestOptions.data,
//                 queryParameters: error.requestOptions.queryParameters,
//               );
              
//               return handler.resolve(cloneReq);
//             } catch (e) {
//               // Refresh token failed, logout user
//               await _secureStorage.deleteAll();
//               // TODO: Navigate to login screen
//             }
//           }
//         }
//         return handler.next(error);
//       },
//     ));
//   }
  
//   // Auth methods
//   Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
//     try {
//       final response = await _dio.post('/auth/token/', data: {
//         'phone_number': phoneNumber,
//         'password': password,
//       });
      
//       final accessToken = response.data['access'];
//       final refreshToken = response.data['refresh'];
      
//       await _secureStorage.write(key: 'access_token', value: accessToken);
//       await _secureStorage.write(key: 'refresh_token', value: refreshToken);
      
//       return response.data;
//     } catch (e) {
//       rethrow;
//     }
//   }
  
//   Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
//     try {
//       final response = await _dio.post('/users/', data: userData);
//       return response.data;
//     } catch (e) {
//       rethrow;
//     }
//   }
  
//   Future<void> logout() async {
//     await _secureStorage.deleteAll();
//   }
  
//   // User methods
//   Future<Map<String, dynamic>> getCurrentUser() async {
//     try {
//       final response = await _dio.get('/users/me/');
//       return response.data;
//     } catch (e) {
//       rethrow;
//     }
//   }
  
//   Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
//     try {
//       final response = await _dio.patch('/users/me/', data: userData);
//       return response.data;
//     } catch (e) {
//       rethrow;
//     }
//   }
  
//   // Ride methods
//   Future<List<Map<String, dynamic>>> getRides() async {
//     try {
//       final response = await _dio.get('/rides/');
//       return List<Map<String, dynamic>>.from(response.data);
//     } catch (e) {
//       rethrow;
//     }
//   }
  
//   Future<Map<String, dynamic>> createRide(Map<String, dynamic> rideData) async {
//     try {
//       final response = await _dio.post('/rides/', data: rideData);
//       return response.data;
//     } catch (e) {
//       rethrow;
//     }
//   }
  
//   Future<Map<String, dynamic>> getRide(String rideId) async {
//     try {
//       final response = await _dio.get('/rides/$rideId/');
//       return response.data;
//     } catch (e) {
//       rethrow;
//     }
//   }
  
//   Future<Map<String, dynamic>> updateRideStatus(String rideId, String status) async {
//     try {
//       final response = await _dio.post('/rides/$rideId/update_status/', data: {
//         'status': status,
//       });
//       return response.data;
//     } catch (e) {
//       rethrow;
//     }
//   }
  
//   Future<Map<String, dynamic>> acceptRide(String rideId) async {
//     try {
//       final response = await _dio.post('/rides/$rideId/accept/');
//       return response.data;
//     } catch (e) {
//       rethrow;
//     }
//   }
  
//   // Driver methods
//   Future<Map<String, dynamic>> updateDriverLocation(double latitude, double longitude, bool isOnline) async {
//     try {
//       final response = await _dio.post('/drivers/location/', data: {
//         'latitude': latitude,
//         'longitude': longitude,
//         'is_online': isOnline,
//       });
//       return response.data;
//     } catch (e) {
//       rethrow;
//     }
//   }
  
//   Future<List<Map<String, dynamic>>> getNearbyDrivers(double latitude, double longitude) async {
//     try {
//       final response = await _dio.get('/drivers/nearby/', queryParameters: {
//         'latitude': latitude,
//         'longitude': longitude,
//       });
//       return List<Map<String, dynamic>>.from(response.data);
//     } catch (e) {
//       rethrow;
//     }
//   }
// }