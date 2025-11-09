// lib/src/features/auth/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:vms_resident_app/src/features/auth/models/resident_model.dart';
import 'package:vms_resident_app/src/features/auth/repositories/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  Resident? _resident;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authRepository);

  Resident? get resident => _resident;
  bool get isLoggedInState => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

Future<bool> isLoggedIn() async {
    final token = await this.token;
    if (token != null) {
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } else {
      _isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }

  // ==========================
  // Login
  // ==========================
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _resident = await _authRepository.login(email, password);
      _isLoggedIn = true;
    } catch (e) {
      _isLoggedIn = false;
      // ⭐️ FIX: Correctly assign error message from caught exception
      _errorMessage = e.toString().contains('Exception:') 
                      ? e.toString().substring(e.toString().indexOf(':') + 1).trim()
                      : e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

// ==========================
// Token Getter (Production Safe)
// ==========================
Future<String?> get token async {
  try {
    return await _secureStorage.read(key: 'jwt_token');
  } catch (e) {
    debugPrint('Error reading token: $e');
    return null;
  }
}

  // ==========================
  // Logout
  // ==========================
  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.logout(); 
      _resident = null;
      _isLoggedIn = false;
    } catch (e) {
      debugPrint('Logout API failed: $e');
      _resident = null;
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================
  // Forgot Password
  // ==========================
  Future<bool> requestPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.forgotPassword(email);
      return true;
    } catch (e) {
      // ⭐️ FIX: Correctly assign error message from caught exception
      _errorMessage = e.toString().contains('Exception:') 
                      ? e.toString().substring(e.toString().indexOf(':') + 1).trim()
                      : e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
// ==========================
// Update Resident Profile (Sync Frontend + Backend)
// ==========================
Future<void> updateResidentProfile(Map<String, dynamic> updatedData) async {
  if (_resident == null) return;

  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    // 🔹 Update on backend first
    final updatedResident = await _authRepository.updateResidentProfile(
      _resident!.id,
      updatedData,
    );

    // 🔹 Then update locally (use real fields, not fullName)
    _resident = _resident!.copyWith(
      firstName: updatedResident.firstName,
      lastName: updatedResident.lastName,
      profilePicture: updatedResident.profilePicture ??
          updatedData['profile_picture'] ??
          _resident!.profilePicture,
      phone: updatedResident.phone ??
          updatedData['phone'] ??
          _resident!.phone,
    );

    notifyListeners();
  } catch (e) {
    debugPrint('Profile update failed: $e');
    _errorMessage = e.toString().contains('Exception:')
        ? e.toString().substring(e.toString().indexOf(':') + 1).trim()
        : e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


}
