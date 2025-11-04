import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vms_resident_app/src/features/visitor_codes/providers/visit_history_provider.dart';
import 'package:vms_resident_app/src/features/visitor_codes/repositories/visitor_code_repository.dart';

class CodeProvider extends ChangeNotifier {
  final VisitorCodeRepository _repository;
  CodeProvider(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _generatedCodeData;
  Map<String, dynamic>? get generatedCodeData => _generatedCodeData;

  /// Generate a visitor code
  Future<void> generateCode({
    required BuildContext context,
    String? visitorName,
    required String visitDate,
    required String startTime,
    required String endTime,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.generateCode(
        visitDate,
        startTime,
        endTime,
        visitorName,
      );

      _generatedCodeData = response['data'] ?? response;

      // ✅ Force status to 'pending' locally for immediate UI update
      if (_generatedCodeData != null) {
        _generatedCodeData!['status'] = 'pending';

        // ✅ Immediately insert into the HistoryProvider list
        // ignore: use_build_context_synchronously
        final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
        historyProvider.addTemporaryPendingCode(_generatedCodeData!);
      }
    } catch (e) {
      debugPrint('Error generating visitor code: $e');
      _generatedCodeData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancel visitor code
  Future<void> cancelVisitorCode(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.cancelVisitorCode(id);
      _generatedCodeData = null;
    } catch (e) {
      debugPrint('Error cancelling visitor code: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
