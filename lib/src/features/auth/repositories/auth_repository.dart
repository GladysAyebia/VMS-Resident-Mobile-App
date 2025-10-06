import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vms_resident_app/src/core/api_client.dart';
import 'package:vms_resident_app/src/core/error_handler.dart';
import 'package:vms_resident_app/src/features/auth/models/resident_model.dart';

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
}
