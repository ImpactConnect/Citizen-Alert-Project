import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show debugPrint;
import 'dart:typed_data';
import '../models/report_model.dart';
import '../config/supabase_config.dart';
import 'package:uuid/uuid.dart';
import '../models/comment_model.dart';

class ReportService {
  final _supabase = Supabase.instance.client;

  // Create a new report
  Future<String> createReport(ReportModel report) async {
    try {
      final reportId = const Uuid().v4();
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from(SupabaseConfig.reportsTable)
          .insert({
            'id': reportId,
            'user_id': currentUser.id,
            'title': report.title,
            'description': report.description,
            'location': report.location,
            'category': report.category.toString().split('.').last,
            'status': report.status.toString().split('.').last,
            'priority': report.priority,
            'created_at': DateTime.now().toIso8601String(),
            'media_urls': report.mediaUrls,
            'video_url': report.videoUrl,
          })
          .select()
          .single();

      return response['id'];
    } catch (e) {
      debugPrint('Create report error: $e');
      rethrow;
    }
  }

  // Upload media file
  Future<String> uploadMedia(String filePath, String reportId) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
      final path = '$reportId/$fileName';

      if (kIsWeb) {
        await _supabase.storage
            .from(SupabaseConfig.reportMediaBucket)
            .upload(path, filePath,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  upsert: false,
                ));
      } else {
        await _supabase.storage
            .from(SupabaseConfig.reportMediaBucket)
            .upload(path, filePath);
      }

      return _supabase.storage
          .from(SupabaseConfig.reportMediaBucket)
          .getPublicUrl(path);
    } catch (e) {
      debugPrint('Upload media error: $e');
      rethrow;
    }
  }

  // Upload video file
  Future<String> uploadVideo(String filePath, String reportId) async {
    try {
      final fileName =
          'video_${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
      final path = '$reportId/$fileName';

      if (kIsWeb) {
        await _supabase.storage
            .from(SupabaseConfig.reportMediaBucket)
            .upload(path, filePath,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  upsert: false,
                ));
      } else {
        await _supabase.storage
            .from(SupabaseConfig.reportMediaBucket)
            .upload(path, filePath);
      }

      return _supabase.storage
          .from(SupabaseConfig.reportMediaBucket)
          .getPublicUrl(path);
    } catch (e) {
      debugPrint('Upload video error: $e');
      rethrow;
    }
  }

  // Stream of reports
  Stream<List<ReportModel>> getReports({
    String? userId,
    ReportCategory? category,
    ReportStatus? status,
  }) {
    return _supabase
        .from(SupabaseConfig.reportsTable)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .handleError((error) {
          debugPrint('Realtime subscription error: $error');
          // Return empty list on error to keep the stream alive
          return [];
        }, test: (error) => error is RealtimeSubscribeException)
        .map((data) {
          try {
            return data.map((json) => ReportModel.fromMap(json)).toList();
          } catch (e) {
            debugPrint('Error mapping reports: $e');
            return [];
          }
        });
  }

  // Get reports once (non-stream)
  Future<List<ReportModel>> getReportsOnce({
    String? userId,
    ReportCategory? category,
    ReportStatus? status,
  }) async {
    try {
      var query = _supabase.from(SupabaseConfig.reportsTable).select();

      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      if (category != null) {
        query = query.eq('category', category.toString().split('.').last);
      }
      if (status != null) {
        query = query.eq('status', status.toString().split('.').last);
      }

      final response = await query.order('created_at', ascending: false);
      return response.map((json) => ReportModel.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Get reports error: $e');
      rethrow;
    }
  }

  // Update report
  Future<void> updateReport(ReportModel report) async {
    try {
      await _supabase
          .from(SupabaseConfig.reportsTable)
          .update(report.toMap())
          .eq('id', report.id);
    } catch (e) {
      debugPrint('Update report error: $e');
      rethrow;
    }
  }

  // Delete report
  Future<void> deleteReport(String reportId) async {
    try {
      await _supabase
          .from(SupabaseConfig.reportsTable)
          .delete()
          .eq('id', reportId);
    } catch (e) {
      debugPrint('Delete report error: $e');
      rethrow;
    }
  }

  // Update report status
  Future<void> updateReportStatus(String reportId, ReportStatus status,
      {String? adminComment}) async {
    try {
      await _supabase.from(SupabaseConfig.reportsTable).update({
        'status': status.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
        if (adminComment != null) 'admin_comment': adminComment,
      }).eq('id', reportId);
    } catch (e) {
      debugPrint('Update report status error: $e');
      rethrow;
    }
  }

  Stream<List<CommentModel>> getComments(String reportId) {
    return _supabase
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('report_id', reportId)
        .order('created_at')
        .map((data) => data.map((json) => CommentModel.fromMap(json)).toList());
  }

  Future<void> addComment(CommentModel comment) async {
    try {
      await _supabase.from('comments').insert(comment.toMap());
    } catch (e) {
      debugPrint('Add comment error: $e');
      rethrow;
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _supabase.from('comments').delete().eq('id', commentId);
    } catch (e) {
      debugPrint('Delete comment error: $e');
      rethrow;
    }
  }
}
