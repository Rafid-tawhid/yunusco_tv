import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    // 1. Create the Dio instance with a base URL
    dio = Dio(BaseOptions(
      baseUrl: 'http://202.74.243.118:8090/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // 2. Add Logging Interceptor (only in debug mode)
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (object) => debugPrint(object.toString()),
      ));
    }

    // 3. Add an Interceptor for potential future needs (Auth, Headers, etc.)
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        // This is where you would automatically add auth tokens
        // options.headers['Authorization'] = 'Bearer $yourToken';
        debugPrint('🌐 API Request: ${options.uri}');
        handler.next(options);
      },
      onResponse: (Response response, ResponseInterceptorHandler handler) {
        debugPrint('✅ API Response: ${response.statusCode}');
        handler.next(response);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) {
        debugPrint('❌ API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // A helper method to handle standard HTTP errors and parsing
  // This simplifies the code in the service classes.
  Future<dynamic> getRequest(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      // You can customize error messages based on status code
      final errorMessage = switch (e.response?.statusCode) {
        404 => 'Resource not found',
        500 => 'Internal server error',
        _ => 'Failed to load data: ${e.message}',
      };
      debugPrint(errorMessage);
      throw Exception(errorMessage);
    }
  }
}