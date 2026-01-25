class ApiEndpoints {
  ApiEndpoints._();
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static const Duration connectionTimeout = Duration(seconds: 30);

  //login signup endpoints

  static const String userRegister = '/auth/register';
  static const String userLogin = '/auth/login';
}
