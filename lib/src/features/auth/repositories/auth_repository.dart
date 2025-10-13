import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vms_resident_app/src/core/api_client.dart';
import 'package:vms_resident_app/src/core/error_handler.dart';
import 'package:vms_resident_app/src/features/auth/models/resident_model.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthRepository(this._apiClient);

  Future<Resident> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final responseData = response.data['data'];
      final token = responseData['token'];
      await _secureStorage.write(key: 'jwt_token', value: token);

      return Resident.fromJson(responseData['user']);
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> logout() async {
    // 1. Invalidate session token on the backend (optional but recommended)
    try {
      // Assuming you have a logout endpoint to invalidate the JWT on the server
      await _apiClient.dio.post('/auth/logout');
    } on DioException catch (e) {
      // ✅ FIX: Replaced print() with debugPrint()
      debugPrint('Warning: Failed to invalidate server session: ${e.message}');
    }

    // 2. Clear the JWT token from local secure storage
    await _secureStorage.delete(key: 'jwt_token');
  }
}