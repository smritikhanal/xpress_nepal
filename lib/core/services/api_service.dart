import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:xpress_nepal/core/constants/api_constants.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Response wrapper for API calls
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    required this.statusCode,
  });
}

/// Service class for making HTTP requests to the backend API
class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  String? _authToken;

  /// Set the authentication token for authenticated requests
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Get the current auth token
  String? get authToken => _authToken;

  /// Clear the authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Get default headers for requests
  Map<String, String> _getHeaders({bool requiresAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  /// Handle API response and parse errors
  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    final Map<String, dynamic> body;

    try {
      body = json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Invalid response from server',
        statusCode: response.statusCode,
      );
    }

    final success =
        body['success'] as bool? ??
        response.statusCode >= 200 && response.statusCode < 300;
    final message = body['message'] as String?;

    return ApiResponse(
      success: success,
      message: message,
      data: body,
      statusCode: response.statusCode,
    );
  }

  /// Make a POST request
  Future<ApiResponse<Map<String, dynamic>>> post(
    String url, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(const Duration(seconds: ApiConstants.connectionTimeout));

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } on http.ClientException {
      return ApiResponse(
        success: false,
        message: 'Unable to connect to server. Please try again.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Make a GET request
  Future<ApiResponse<Map<String, dynamic>>> get(
    String url, {
    Map<String, String>? queryParams,
    bool requiresAuth = false,
  }) async {
    try {
      var uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await _client
          .get(uri, headers: _getHeaders(requiresAuth: requiresAuth))
          .timeout(const Duration(seconds: ApiConstants.connectionTimeout));

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } on http.ClientException {
      return ApiResponse(
        success: false,
        message: 'Unable to connect to server. Please try again.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Make a PUT request
  Future<ApiResponse<Map<String, dynamic>>> put(
    String url, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(const Duration(seconds: ApiConstants.connectionTimeout));

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } on http.ClientException {
      return ApiResponse(
        success: false,
        message: 'Unable to connect to server. Please try again.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Make a DELETE request
  Future<ApiResponse<Map<String, dynamic>>> delete(
    String url, {
    bool requiresAuth = false,
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: _getHeaders(requiresAuth: requiresAuth),
          )
          .timeout(const Duration(seconds: ApiConstants.connectionTimeout));

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } on http.ClientException {
      return ApiResponse(
        success: false,
        message: 'Unable to connect to server. Please try again.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Make a Multipart POST request (for file uploads)
  Future<ApiResponse<Map<String, dynamic>>> postMultipart(
    String url, {
    required File file,
    String fieldName = 'image',
    Map<String, String>? fields,
    bool requiresAuth = false,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers['Accept'] = 'application/json';
      if (requiresAuth && _authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add file
      // Determine content type from file extension
      final extension = file.path.split('.').last.toLowerCase();
      MediaType contentType;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = MediaType('image', 'jpeg');
          break;
        case 'png':
          contentType = MediaType('image', 'png');
          break;
        case 'gif':
          contentType = MediaType('image', 'gif');
          break;
        case 'webp':
          contentType = MediaType('image', 'webp');
          break;
        case 'heic':
          contentType = MediaType('image', 'heic');
          break;
        default:
          contentType = MediaType('image', 'jpeg'); // Default fallback
      }

      final multipartFile = await http.MultipartFile.fromPath(
        fieldName,
        file.path,
        contentType: contentType,
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Upload failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Make a Multipart PUT request (for file uploads with update)
  Future<ApiResponse<Map<String, dynamic>>> putMultipart(
    String url, {
    File? file,
    String fieldName = 'image',
    Map<String, String>? fields,
    bool requiresAuth = false,
  }) async {
    try {
      final request = http.MultipartRequest('PUT', Uri.parse(url));

      // Add headers
      request.headers['Accept'] = 'application/json';
      if (requiresAuth && _authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add file if provided
      if (file != null) {
        // Determine content type from file extension
        final extension = file.path.split('.').last.toLowerCase();
        MediaType contentType;

        switch (extension) {
          case 'jpg':
          case 'jpeg':
            contentType = MediaType('image', 'jpeg');
            break;
          case 'png':
            contentType = MediaType('image', 'png');
            break;
          case 'gif':
            contentType = MediaType('image', 'gif');
            break;
          case 'webp':
            contentType = MediaType('image', 'webp');
            break;
          case 'heic':
            contentType = MediaType('image', 'heic');
            break;
          default:
            contentType = MediaType('image', 'jpeg'); // Default fallback
        }

        final multipartFile = await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: contentType,
        );
        request.files.add(multipartFile);
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Update failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
}
