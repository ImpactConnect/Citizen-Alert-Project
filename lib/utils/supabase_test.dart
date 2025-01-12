import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_error_handler.dart';

class SupabaseTest {
  final _supabase = Supabase.instance.client;

  Future<void> testConnection() async {
    try {
      print('\nTesting Supabase connection...\n');

      // Test basic connection
      final response = await _supabase.from('users').select().limit(1);
      print('Connection successful: ${response != null}');
    } catch (e) {
      print('Error type: ${e.runtimeType}');
      print('Raw error: $e');
      throw 'Connection error: ${SupabaseErrorHandler.getErrorMessage(e)}';
    }
  }
}
