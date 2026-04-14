import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  SupabaseClient get _supabase => Supabase.instance.client;

  // Stream of auth state changes (useful for rebuilding UI)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Current session (user is logged in) or null
  Session? get currentSession => _supabase.auth.currentSession;

  // Current user (if logged in)
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      return response;
    } on AuthException catch (e) {
      // Re-throw with a user-friendly message
      throw Exception(e.message);
    }
  }

  // Verify email with OTP code
  Future<AuthResponse> verifyEmail({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Reset password (sends email with reset link)
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Update user metadata (e.g., display name)
  Future<User?> updateProfile(Map<String, dynamic> data) async {
    try {
      // Fix: Wrap the map in UserAttributes
      final response = await _supabase.auth.updateUser(
        UserAttributes(data: data),
      );
      return response.user;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }
}