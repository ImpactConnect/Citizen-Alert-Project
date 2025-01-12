class SupabaseConfig {
  // Get these values from Supabase Dashboard > Settings > API
  static const String url = 'https://fsvmwzmuvqjqsdztyfkc.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzdm13em11dnFqcXNkenR5ZmtjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY0MzUzNTEsImV4cCI6MjA1MjAxMTM1MX0.s3erGF38rjZEA__H8C_INWNpilz2wAGnWsW1KObIDWA';

  // Table names
  static const String usersTable = 'users';
  static const String reportsTable = 'reports';

  // Storage buckets
  static const String reportMediaBucket = 'reports_media';
  static const String userAvatarsBucket = 'user_avatars';
}
