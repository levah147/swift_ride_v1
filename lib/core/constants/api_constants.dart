class ApiConstants {
  // Base URL - Change this to your Django backend URL
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  
  // Authentication endpoints
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String logout = '/auth/logout/';
  static const String refreshToken = '/auth/token/refresh/';
  static const String profile = '/auth/profile/';
  static const String changePassword = '/auth/change-password/';
  
  // User data endpoints
  static const String locations = '/user/locations/';
  static const String paymentMethods = '/user/payment-methods/';
  
  // Ride endpoints
  static const String categories = '/categories/';
  static const String rides = '/rides/';
  static const String activeRide = '/rides/active/';
  static const String rideHistory = '/rides/history/';
  
  // Home page data
  static const String homeData = '/home/';
}
