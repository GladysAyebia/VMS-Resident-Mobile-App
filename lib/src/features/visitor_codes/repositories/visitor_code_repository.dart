// VisitorCodeRepository.dart

import 'package:vms_resident_app/src/core/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class VisitorCodeRepository {
  final ApiClient _apiClient;

  VisitorCodeRepository(this._apiClient);

  // ===================================
// 1. VISIT HISTORY METHOD (Used by HistoryProvider)
// ===================================

/// Get the resident's visit history
Future<List<dynamic>> getVisitHistory({
  String? status,
  String? fromDate,
  String? toDate,
  int? limit,
  int? offset,
}) async {
  try {
    final queryParams = {
      'status': status,
      'from_date': fromDate,
      'to_date': toDate,
      'limit': limit,
      'offset': offset,
    };

    if (status == 'all') {
      queryParams.remove('status');
    }

    debugPrint('Calling /codes/my-codes with params: $queryParams');

    final response = await _apiClient.dio.get(
      '/codes/my-codes',
      queryParameters: queryParams,
    );

    debugPrint('Status: ${response.statusCode}');
    debugPrint('Raw Response: ${response.data}');

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;

      if (data is List) {
        debugPrint('Response is a List with ${data.length} items.');
        return data;
      } else if (data is Map) {
        debugPrint('Response is a Map. Checking known structures...');

        final innerData = data['data'];

       if (innerData is Map && innerData['codes'] is List) {
  debugPrint('✅ Found data["data"]["codes"] as List');
  final codes = innerData['codes'] as List<dynamic>;

  // ✅ Normalize field names for UI compatibility
  final normalized = codes.map((item) {
  if (item is Map<String, dynamic>) {
    return {
      'id': item['id'],
      'code': item['code'],
      'status': item['status'],
      // ✅ handle all name variations
      'visitor_name': item['visitor_name'] ??
          item['visitorName'] ?? // ← ADD THIS
          item['visitor']?['name'] ??
          'Unnamed Visitor',
      // ✅ handle all date variations
      'visit_date': item['visit_date'] ??
          item['visitDate'] ??
          item['visit_date_time'] ??
          '',
    };
  }
  return item;
}).toList();

  return normalized;
}
 else if (innerData is Map && innerData['entries'] is List) {
          debugPrint('✅ Found data["data"]["entries"] as List');
          return innerData['entries'] as List<dynamic>;
        } else if (innerData is List) {
          debugPrint('✅ Found data["data"] as List');
          return innerData;
        } else if (innerData is Map && innerData['rows'] is List) {
          debugPrint('✅ Found data["data"]["rows"] as List');
          return innerData['rows'];
        } else if (innerData is Map && innerData['visits'] is List) {
          debugPrint('✅ Found data["data"]["visits"] as List');
          return innerData['visits'];
        } else {
          debugPrint('⚠️ Unknown map structure: $innerData');
          return [];
        }
      } else {
        debugPrint('⚠️ Unexpected data type: ${data.runtimeType}');
        return [];
      }
    }

    debugPrint('⚠️ Non-200 response or empty data, returning empty list');
    return [];
  } on DioException catch (e) {
    debugPrint('❌ DioException: ${e.response?.data ?? e.message}');
    throw Exception(
      'Error fetching history: ${e.response?.data ?? e.message}',
    );
  } catch (e) {
    debugPrint('❌ Unexpected error: $e');
    throw Exception('Error fetching history: $e');
  }
}


  // ===================================
  // 2. CODE MANAGEMENT METHODS (Used by CodeProvider)
  // ===================================


  /// Generate a new visitor access code
  Future<Map<String, dynamic>> generateCode(
    String visitDate,
    String startTime,
    String endTime,
    String visitorName,
  ) async {
    try {
      final formattedStartTime =
          startTime.length > 5 ? startTime.substring(0, 5) : startTime;
      final formattedEndTime =
          endTime.length > 5 ? endTime.substring(0, 5) : endTime; 

      final response = await _apiClient.dio.post(
        '/codes/generate',
        data: {
          'visit_date': visitDate,
          'start_time': formattedStartTime, // FIX: Used formattedStartTime
          'end_time': formattedEndTime,     // FIX: Used formattedEndTime
          'visitor_name': visitorName,
        },
      );
      
      if (response.statusCode == 201 && response.data != null) {
        debugPrint('✅ Code generated successfully: ${response.data}');
        return response.data;
      } else {
        throw Exception('Failed to generate visitor code');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error generating code: ${e.response?.data ?? e.message}');
      throw Exception(
        'Error generating code: ${e.response?.data ?? e.message}',
      );
    }
  }

  /// ✅ Cancel a visitor access code (DELETE /codes/{id})
  Future<void> cancelVisitorCode(String codeId) async {
    try {
      final response = await _apiClient.dio.delete('/codes/$codeId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to cancel visitor code');
      }

      debugPrint('🗑️ Visitor code $codeId cancelled successfully.');
    } on DioException catch (e) {
      debugPrint('❌ Error cancelling code: ${e.response?.data ?? e.message}');
      throw Exception(
        'Error cancelling code: ${e.response?.data ?? e.message}',
      );
    }
  }
}
