//lib/src/features/visitor_codes/repositories/visit_history_repository.dart

import 'package:vms_resident_app/src/core/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class VisitorCodeRepository {
  final ApiClient _apiClient;

  VisitorCodeRepository(this._apiClient);

  /// Get the resident's visit history
  Future<List<dynamic>> getVisitHistory({
    String? fromDate,
    String? toDate,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (fromDate != null && fromDate.toLowerCase() != 'nan') {
        queryParams['from_date'] = fromDate;
      }
      if (toDate != null && toDate.toLowerCase() != 'nan') {
        queryParams['to_date'] = toDate;
      }

      debugPrint('📡 Calling /codes/my-history with params: $queryParams');

      final response = await _apiClient.dio.get(
        '/codes/my-history',
        queryParameters: queryParams,
      );

      // 🧾 Log full response info
      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📦 Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data is List) {
          debugPrint('✅ Response is a List with ${data.length} items.');
          return data;
        } else if (data is Map) {
          debugPrint('✅ Response is a Map. Checking known structures...');
          if (data['data'] is List) {
            debugPrint('📁 Found data["data"] as List');
            return data['data'];
          } else if (data['data'] is Map && data['data']['rows'] is List) {
            debugPrint('📁 Found data["data"]["rows"] as List');
            return data['data']['rows'];
          } else if (data['data'] is Map && data['data']['visits'] is List) {
            debugPrint('📁 Found data["data"]["visits"] as List');
            return data['data']['visits'];
          } else {
            debugPrint('⚠️ Unknown map structure: $data');
            return [];
          }
        } else {
          debugPrint('⚠️ Unexpected data type: ${data.runtimeType}');
          return [];
        }
      }

      // ✅ Fallback return for unexpected responses
      debugPrint('⚠️ Non-200 response: returning empty list');
      return [];
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.response?.data ?? e.message}');
      throw Exception(
          'Error fetching history: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Error fetching history: $e');
    }
  }
}
