import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../config/supabase_config.dart';

class DatabaseService {
  final _supabase = Supabase.instance.client;

  Future<void> saveUser(UserModel user) async {
    try {
      await _supabase.from(SupabaseConfig.usersTable).upsert(user.toMap());
    } catch (e) {
      print('Save user error: $e');
      rethrow;
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _supabase.from(SupabaseConfig.usersTable).select();
      return response.map((json) => UserModel.fromMap(json)).toList();
    } catch (e) {
      print('Get users error: $e');
      rethrow;
    }
  }
}
