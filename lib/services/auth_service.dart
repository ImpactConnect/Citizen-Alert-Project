import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Stream of auth changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign in with email and password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userData = await getUserData(response.user!.id);
        return userData;
      }
      return null;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = UserModel(
          uid: response.user!.id,
          email: email,
          fullName: fullName,
          role: 'citizen',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _supabase.from('users').insert(user.toMap());
        return user;
      }
      return null;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      final response =
          await _supabase.from('users').select().eq('uid', uid).maybeSingle();

      if (response == null) return null;
      return UserModel.fromMap(response);
    } catch (e) {
      print('Get user data error: $e');
      // Instead of returning null, which might cause cascade issues
      // rethrow the error so it can be handled by the caller
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Add this method to AuthService class
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  // Add this method to register admin users (only existing admins can create new admins)
  Future<UserModel?> registerAdmin(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      // Check if the current user is an admin
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw 'Not authenticated';
      }

      final currentUserData = await getUserData(currentUser.id);
      if (currentUserData?.role != 'admin') {
        throw 'Only admins can create other admin accounts';
      }

      // Register the new admin
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = UserModel(
          uid: response.user!.id,
          email: email,
          fullName: fullName,
          role: 'admin', // Set role as admin
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _supabase.from('users').insert(user.toMap());
        return user;
      }
      return null;
    } catch (e) {
      print('Admin registration error: $e');
      rethrow;
    }
  }

  // Add this method for guest login
  Future<UserModel?> signInAsGuest() async {
    try {
      // Create a temporary guest user model
      return UserModel(
        uid: 'guest',
        email: 'guest@temp.com',
        fullName: 'Guest User',
        role: 'guest',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
    } catch (e) {
      print('Guest login error: $e');
      rethrow;
    }
  }
}
