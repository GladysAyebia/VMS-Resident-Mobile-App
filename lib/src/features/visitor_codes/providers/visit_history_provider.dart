import 'package:flutter/foundation.dart';
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

    final String apiStatus = uiToApiStatus[uiFilter] ?? 'all';
    try {
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

  /// Add newly generated pending code immediately
  void addTemporaryPendingCode(Map<String, dynamic> codeData) {
    if (!_historyList.any((e) => e['id'] == codeData['id'])) {
      _historyList.insert(0, codeData);
      notifyListeners();
    }
  }

  /// ✅ Production-ready delete function
  Future<void> deleteVisitorCode(String codeId) async {
    try {
      _isDeleting = true;
      notifyListeners();

      await _repository.cancelVisitorCode(codeId);

      // Remove the deleted code from the list
      _historyList.removeWhere((code) => code['id'] == codeId);

      // Optionally refresh from server to ensure latest state
      // await setFilterByStatus('All');

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
