/// API Constants for backend connectivity
class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  // Base URL - change this for production
  // For Android emulator use: 10.0.2.2
  // For iOS simulator use: localhost
  // For real device use your computer's IP address
  static const String baseUrl = 'http://10.0.2.2:3000';

  // API version
  static const String apiVersion = '/api';

  // Full API URL
  static const String apiUrl = '$baseUrl$apiVersion';
  // Auth endpoints
  static const String register = '$apiUrl/auth/register';
  static const String login = '$apiUrl/auth/login';
  static const String logout = '$apiUrl/auth/logout';

  // User endpoints
  static const String users = '$apiUrl/users';
  static const String userProfile = '$apiUrl/users/profile';

  // Timeout durations (in seconds)
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
}
