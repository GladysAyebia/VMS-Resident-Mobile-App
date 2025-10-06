
import 'package:flutter/material.dart';
import 'package:vms_resident_app/src/features/auth/models/resident_model.dart';
import 'package:vms_resident_app/src/features/auth/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  Resident? _resident;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authRepository);

  Resident? get resident => _resident;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _resident = await _authRepository.login(email, password);
      _isLoggedIn = true;
    } catch (e) {
      _isLoggedIn = false;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
