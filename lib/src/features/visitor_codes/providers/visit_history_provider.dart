//lib/src/features/visitor_codes/providers/visit_history_provider.dart
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:vms_resident_app/src/features/visitor_codes/repositories/visitor_code_repository.dart';

class HistoryProvider extends ChangeNotifier {
  final VisitorCodeRepository _repository;
  HistoryProvider(this._repository);

  List<dynamic> _historyList = [];
  List<dynamic> get historyList => _historyList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  String? errorMessage;

  Future<void> setFilterByStatus(String uiFilter) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 🧩 Always fetch all records, as client-side logic determines the real-time status.
      final history = await _repository.getVisitHistory(
        status: 'all',
        limit: 50,
        offset: 0,
      );

      final now = DateTime.now();

      // ✅ Compute real status based on both date and time
      final processed = history.map((code) {
        final visitDateStr = code['visit_date'];
        final startTimeStr = code['start_time'];
        final endTimeStr = code['end_time'];
        String status = (code['status'] ?? '').toLowerCase();

        try {
          if (visitDateStr != null && endTimeStr != null) {
            final visitDate = DateTime.parse(visitDateStr);
            final endTime = DateFormat('HH:mm').parse(endTimeStr);

            final endDateTime = DateTime(
              visitDate.year,
              visitDate.month,
              visitDate.day,
              endTime.hour,
              endTime.minute,
            );

            if (status != 'used' && status != 'cancelled') {
              if (startTimeStr != null) {
                final startTime = DateFormat('HH:mm').parse(startTimeStr);
                final startDateTime = DateTime(
                  visitDate.year,
                  visitDate.month,
                  visitDate.day,
                  startTime.hour,
                  startTime.minute,
                );

                // 🧠 Refined logic
                if (now.isBefore(startDateTime)) {
                  status = 'pending'; // Visit not started yet
                } else if (now.isAfter(endDateTime)) {
                  status = 'expired'; // Visit window ended
                } else {
                  status = 'pending'; // Ongoing visit (still valid)
                }
              } else {
                // Fallback if no start_time available
                status = now.isBefore(endDateTime) ? 'pending' : 'expired';
              }
            }
          }
        } catch (e) {
          debugPrint('⚠️ Date/time parse error: $e');
        }

        code['status'] = status;
        return code;
      }).toList();

      // ✅ Apply UI filter AFTER recomputing statuses
      if (uiFilter == 'All') {
        _historyList = processed;
      } else {
        // Map UI filter names to internal status names
        String filterStatus = uiFilter.toLowerCase();
        if (filterStatus == 'validated') {
          filterStatus = 'used'; // Map 'Validated' -> 'used'
        }
        
        _historyList = processed
            .where(
                (code) => (code['status'] ?? '').toLowerCase() == filterStatus)
            .toList();
      }

      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to load history: $e';
      debugPrint(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addTemporaryPendingCode(Map<String, dynamic> codeData) {
    if (!_historyList.any((e) => e['id'] == codeData['id'])) {
      _historyList.insert(0, codeData);
      notifyListeners();
    }
  }

  Future<void> deleteVisitorCode(String codeId) async {
    try {
      _isDeleting = true;
      notifyListeners();

      await _repository.cancelVisitorCode(codeId);
      _historyList.removeWhere((code) => code['id'] == codeId);

      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to delete visitor code: $e';
      debugPrint(errorMessage);
      rethrow;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}
