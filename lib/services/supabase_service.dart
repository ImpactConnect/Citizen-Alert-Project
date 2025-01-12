import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Auth methods
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
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

        // Save additional user data
        await _supabase.from(SupabaseConfig.usersTable).insert(user.toMap());

        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final data = await _supabase
            .from(SupabaseConfig.usersTable)
            .select()
            .eq('uid', response.user!.id)
            .single();

        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // User methods
  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final data = await _supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('uid', user.id)
          .single();
      return UserModel.fromMap(data);
    }
    return null;
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
