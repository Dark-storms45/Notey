import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import '../../models/recordings.dart';
import '../../models/course.dart';

class SupabaseService {
  SupabaseClient get _supabase => Supabase.instance.client;

  // --- Auth Helpers ---
  User? get currentUser => _supabase.auth.currentUser;
  String? get userId => currentUser?.id;

  // --- Auth Operations ---

  /// Sign in using Google OAuth
  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        // Replace with your app's redirect URL scheme
        redirectTo: 'com.example.notey://login-callback',
      );
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  /// Sign in using Apple ID
  Future<void> signInWithApple() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'com.example.notey://login-callback',
      );
    } catch (e) {
      throw Exception('Apple sign-in failed: $e');
    }
  }

  /// Send a OTP (One-Time Password) to a phone number
  Future<void> sendPhoneOTP(String phone) async {
    try {
      await _supabase.auth.signInWithOtp(phone: phone);
    } catch (e) {
      throw Exception('Failed to send phone OTP: $e');
    }
  }

  /// Send a OTP (One-Time Password) to an email address
  Future<void> sendEmailOTP(String email) async {
    try {
      await _supabase.auth.signInWithOtp(email: email);
    } catch (e) {
      throw Exception('Failed to send email OTP: $e');
    }
  }

  /// Verify the OTP code received via SMS or Email
  Future<AuthResponse> verifyOTP({
    required String token,
    String? phone,
    String? email,
    required OtpType type,
  }) async {
    try {
      return await _supabase.auth.verifyOTP(
        token: token,
        phone: phone,
        email: email,
        type: type,
      );
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // --- Storage Operations ---

  Future<String> uploadAudio(String localPath) async {
    final file = File(localPath);
    final fileName = p.basename(localPath);
    
    if (userId == null) throw Exception('User must be logged in to upload files');

    final String storagePath = '$userId/$fileName';

    try {
      await _supabase.storage.from('recordings').upload(
            storagePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _supabase.storage.from('recordings').getPublicUrl(storagePath);
    } catch (e) {
      throw Exception('Failed to upload audio to Supabase: $e');
    }
  }

  Future<void> deleteAudio(String storagePath) async {
    try {
      await _supabase.storage.from('recordings').remove([storagePath]);
    } catch (e) {
      print('Failed to delete remote audio: $e');
    }
  }

  // --- Course Operations ---

  Future<Map<String, dynamic>> syncCourse(Course course) async {
    if (userId == null) throw Exception('User must be logged in');

    final data = {
      if (course.supabaseId != null) 'id': course.supabaseId,
      'user_id': userId,
      'name': course.name,
      'instructor': course.instructor,
      'color': course.color,
      'created_at': course.createdAt.toIso8601String(),
    };

    try {
      return await _supabase.from('courses').upsert(data).select().single();
    } catch (e) {
      throw Exception('Failed to sync course: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchRemoteCourses() async {
    if (userId == null) return [];
    return await _supabase.from('courses').select().eq('user_id', userId!);
  }

  // --- Note Operations ---

  Future<Map<String, dynamic>> syncNote(Recording recording) async {
    if (userId == null) throw Exception('User must be logged in');

    final data = {
      if (recording.supabaseId != null) 'id': recording.supabaseId,
      'user_id': userId,
      'title': recording.title,
      'transcript': recording.transcript,
      'summary': recording.summary,
      'duration': recording.duration,
      'course_id': recording.courseId,
      'recorded_at': recording.recordedAt.toIso8601String(),
      'created_at': recording.createdAt.toIso8601String(),
    };

    try {
      return await _supabase.from('notes').upsert(data).select().single();
    } catch (e) {
      throw Exception('Failed to sync note: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchRemoteNotes() async {
    if (userId == null) return [];
    return await _supabase.from('notes').select().eq('user_id', userId!).order('recorded_at', ascending: false);
  }

  Future<void> deleteNote(String supabaseId) async {
    await _supabase.from('notes').delete().eq('id', supabaseId);
  }
}