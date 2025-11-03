import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:vms_resident_app/src/features/visitor_codes/repositories/visitor_code_repository.dart';

/// MAPPING: UI Display Status to API Query Status
const Map<String, String> uiToApiStatus = {
  'All': 'all',
  'Pending': 'active',     // UI Pending → API active
  'Validated': 'used',     // UI Validated → API used
  'Expired': 'expired',    // UI Expired → API expired
  'Cancelled': 'cancelled' // UI Cancelled → API cancelled
};

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

  /// Fetch visit history based on UI filter
 Future<void> setFilterByStatus(String uiFilter) async {
  _isLoading = true;
  notifyListeners();

  // ✅ If Expired tab is selected, fetch all so we can calculate locally
  final String apiStatus = uiFilter == 'Expired'
      ? 'all'
      : (uiToApiStatus[uiFilter] ?? 'all');

  try {
    final history = await _repository.getVisitHistory(
      status: apiStatus,
      limit: 20,
      offset: 0,
    );

    // ✅ Step 1: Apply expiry calculation locally
    List<dynamic> processed = _applyLocalExpiryLogic(history);

    // ✅ Step 2: Apply UI-level filtering
    switch (uiFilter) {
      case 'Pending':
        _historyList = processed
            .where((e) =>
                e['status'] == 'active' || e['status'] == 'pending')
            .toList();
        break;
      case 'Validated':
        _historyList =
            processed.where((e) => e['status'] == 'used').toList();
        break;
      case 'Expired':
        _historyList =
            processed.where((e) => e['status'] == 'expired').toList();
        break;
      case 'Cancelled':
        _historyList =
            processed.where((e) => e['status'] == 'cancelled').toList();
        break;
      default:
        _historyList = processed;
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


  /// ✅ Local expiry check logic
  List<dynamic> _applyLocalExpiryLogic(List<dynamic> list) {
    final now = DateTime.now();

    return list.map((code) {
      try {
        final visitDateStr = code['visit_date'] ?? code['visitDate'];
        if (visitDateStr == null) return code;

        // Parse visit date (assuming format: "YYYY-MM-DD" or "YYYY-MM-DD HH:mm")
        final visitDate = DateFormat('yyyy-MM-dd').parse(visitDateStr, true);

        if (visitDate.isBefore(now)) {
          // Only mark as expired if not already used or cancelled
          final currentStatus = code['status']?.toLowerCase();
          if (currentStatus != 'used' && currentStatus != 'cancelled') {
            code['status'] = 'expired';
          }
        }
      } catch (e) {
        debugPrint('⚠️ Date parsing failed for ${code['id']}: $e');
      }
      return code;
    }).toList();
  }

  /// ✅ Add newly generated "pending" code immediately
  void addTemporaryPendingCode(Map<String, dynamic> codeData) {
    codeData['status'] = codeData['status'] ?? 'pending';

    if (!_historyList.any((e) => e['id'] == codeData['id'])) {
      _historyList.insert(0, codeData);
      notifyListeners();
    }
  }

  /// ✅ Production-ready delete/cancel function
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
