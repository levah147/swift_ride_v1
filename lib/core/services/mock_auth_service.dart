// // lib/core/services/mock_auth_service.dart
// import '../../features/auth/domain/models/user.dart';

// class MockAuthService {
//   User? _currentUser;
  
//   Future<User> login(String phoneNumber, String password) async {
//     // Simulate network delay
//     await Future.delayed(const Duration(seconds: 1));
    
//     if (phoneNumber.endsWith('1234567890') && password == 'password') {
//       _currentUser = User(
//         id: '1',
//         username: 'user1',
//         phoneNumber: phoneNumber,
//         email: 'user@example.com',
//         firstName: 'John',
//         lastName: 'Doe',
//         role: 'rider',
//         isPhoneVerified: true,
//       );
//       return _currentUser!;
//     } else {
//       throw Exception('Invalid credentials');
//     }
//   }
  
//   Future<User> register(String phoneNumber, String password, String firstName, String lastName, String email) async {
//     // Simulate network delay
//     await Future.delayed(const Duration(seconds: 1));
    
//     _currentUser = User(
//       id: '2',
//       username: phoneNumber,
//       phoneNumber: phoneNumber,
//       email: email,
//       firstName: firstName,
//       lastName: lastName,
//       role: 'rider',
//       isPhoneVerified: false,
//     );
    
//     return _currentUser!;
//   }
  
//   Future<void> logout() async {
//     _currentUser = null;
//   }
  
//   Future<User?> getCurrentUser() async {
//     return _currentUser;
//   }
  
//   Future<bool> verifyOtp(String phoneNumber, String otp) async {
//     await Future.delayed(const Duration(seconds: 1));
//     return otp == '1234';
//   }
// }