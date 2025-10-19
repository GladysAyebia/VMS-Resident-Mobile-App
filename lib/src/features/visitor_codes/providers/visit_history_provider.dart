// HistoryProvider.dart

import 'package:flutter/foundation.dart';
import 'package:vms_resident_app/src/features/visitor_codes/repositories/visitor_code_repository.dart';

// MAPPING: UI Display Status to API Query Status
const Map<String, String> uiToApiStatus = {
      'All': 'all',
    'Pending': 'active',    // UI Pending -> API active
    'Validated': 'used',    // UI Validated -> API used
    'Expired': 'expired',   // UI Expired -> API expired
    'Cancelled': 'cancelled' // UI Cancelled -> API cancelled
};


class HistoryProvider extends ChangeNotifier {
  final VisitorCodeRepository _repository;

  HistoryProvider(this._repository);

  List<dynamic> _historyList = [];
  List<dynamic> get historyList => _historyList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? errorMessage;

  // RENAMED and UPDATED method to handle status filtering
  Future<void> setFilterByStatus(String uiFilter) async {
    _isLoading = true;
    notifyListeners();
    
    // Convert UI status to API status
final String apiStatus = uiToApiStatus[uiFilter] ?? 'all';
    try {
      // NOTE: Removed Date logic. If you need dates, you must integrate them here.
      final history = await _repository.getVisitHistory(
        status: apiStatus, 
        limit: 20,
        offset: 0,
      );

      _historyList = history;
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to load history: $e';
      debugPrint(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add pending code immediately after generation
  void addTemporaryPendingCode(Map<String, dynamic> codeData) {
    // Avoid duplicates
    if (!_historyList.any((e) => e['id'] == codeData['id'])) {
      _historyList.insert(0, codeData);
      notifyListeners();
    }
  }
}