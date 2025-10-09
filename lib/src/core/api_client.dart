import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiClient() {
    dio.options.baseUrl = 'https://vmsbackend.vercel.app/api/v1';
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // ✅ GET request method
  Future<Response> get(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final response = await dio.get(endpoint, queryParameters: params);
      return response;
    } on DioException catch (e) { // ← replaced DioError with DioException
      throw Exception(_handleError(e));
    }
  }

  // ✅ POST request method
  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await dio.post(endpoint, data: data);
      return response;
    } on DioException catch (e) { // ← replaced here too
      throw Exception(_handleError(e));
    }
  }

  // ✅ Handle backend or network errors
  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['message'] ??
          'Error: ${error.response?.statusCode}';
    } else {
      return 'Network error: ${error.message}';
    }
  }
}
