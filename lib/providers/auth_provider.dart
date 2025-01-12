import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null && !_user!.isGuest;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  AuthProvider() {
    _initializeUser();
  }

  void _initializeUser() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      try {
        // Try to get existing user data
        final userData = await _supabase
            .from('users')
            .select()
            .eq('uid', session.user.id)
            .single();

        _user = UserModel(
          uid: session.user.id,
          email: session.user.email,
          displayName: userData['full_name'],
          avatarUrl: userData['avatar_url'],
          role: userData['role'] ?? 'user',
        );
      } catch (e) {
        // If user doesn't exist in users table, create a new record
        await _supabase.from('users').insert({
          'uid': session.user.id,
          'email': session.user.email,
          'full_name': session.user.email?.split('@')[0] ?? 'User',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        _user = UserModel(
          uid: session.user.id,
          email: session.user.email,
          displayName: session.user.email?.split('@')[0] ?? 'User',
          role: 'user',
        );
      }
    } else {
      _user = UserModel.guest();
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Create or update user record
      await _supabase.from('users').upsert({
        'uid': response.user!.id,
        'email': response.user!.email,
        'full_name': email.split('@')[0],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'uid');

      _user = UserModel(
        uid: response.user!.id,
        email: response.user!.email,
        displayName: email.split('@')[0],
        role: 'user',
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        _user = UserModel(
          uid: response.user!.id,
          email: response.user!.email,
          displayName: fullName,
          role: 'user',
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> continueAsGuest() async {
    try {
      _setLoading(true);
      _setError(null);

      _user = UserModel.guest();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _supabase.auth.signOut();
      _user = UserModel.guest();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
