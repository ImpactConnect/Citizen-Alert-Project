import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseErrorHandler {
  static String getErrorMessage(dynamic error) {
    print('Error type: ${error.runtimeType}');
    print('Raw error: $error');

    if (error is AuthException) {
      print('Supabase Auth Error: ${error.message}');

      switch (error.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password';
        case 'Email not confirmed':
          return 'Please confirm your email first';
        case 'User already registered':
          return 'This email is already registered';
        default:
          return 'Authentication error: ${error.message}';
      }
    }

    if (error is PostgrestException) {
      print('Database Error: ${error.message}');
      return 'Database error: ${error.message}';
    }

    return 'An error occurred: $error';
  }
}
