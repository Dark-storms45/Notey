import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/auth_service.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _authService.isLoggedIn;
  User? get currentUser => _authService.currentUser;

  AuthProvider() {
    // Listen to auth state changes (e.g., auto-navigate on login)
    _authService.authStateChanges.listen((event) {
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyEmail(String email, String token) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.verifyEmail(email: email, token: token);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resendVerificationEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resendVerificationEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signIn(email: email, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}