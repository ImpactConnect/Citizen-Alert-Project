import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart' show debugPrint;
import '../models/report_model.dart';
import '../config/supabase_config.dart';
import 'package:uuid/uuid.dart';
import '../models/comment_model.dart';
import '../models/vote_model.dart';
import 'dart:io';
import '../models/report_votes.dart';

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
      final file = File(filePath);
      final path = 'reports/$reportId/${file.uri.pathSegments.last}';

      await _supabase.storage.from('media').upload(path, file);

      // Get the public URL after successful upload
      final publicUrl = _supabase.storage.from('media').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Failed to upload media: $e');
      throw Exception('Failed to upload media: $e');
    }
  }

  // Upload video file
  Future<String> uploadVideo(String filePath, String reportId) async {
    try {
      final file = File(filePath);
      final path = 'reports/$reportId/${file.uri.pathSegments.last}';

      await _supabase.storage.from('videos').upload(path, file);

      // Get the public URL after successful upload
      final publicUrl = _supabase.storage.from('videos').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Failed to upload video: $e');
      throw Exception('Failed to upload video: $e');
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

  Future<void> addVote(String reportId, String userId, VoteType type) async {
    try {
      final existingVote = await _supabase
          .from('votes')
          .select()
          .eq('report_id', reportId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingVote != null) {
        // Update existing vote
        await _supabase
            .from('votes')
            .update({'type': type.toString().split('.').last}).eq(
                'id', existingVote['id']);
      } else {
        // Create new vote
        final vote = VoteModel(
          id: const Uuid().v4(),
          reportId: reportId,
          userId: userId,
          type: type,
          createdAt: DateTime.now(),
        );
        await _supabase.from('votes').insert(vote.toMap());
      }
    } catch (e) {
      debugPrint('Add vote error: $e');
      rethrow;
    }
  }

  Future<void> removeVote(String reportId, String userId) async {
    try {
      await _supabase
          .from('votes')
          .delete()
          .eq('report_id', reportId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Remove vote error: $e');
      rethrow;
    }
  }

  Stream<Map<String, int>> getVoteCounts(String reportId) {
    return _supabase
        .from('votes')
        .stream(primaryKey: ['id'])
        .eq('report_id', reportId)
        .map((data) {
          final upvotes = data.where((vote) => vote['type'] == 'upvote').length;
          final downvotes =
              data.where((vote) => vote['type'] == 'downvote').length;
          return {'upvotes': upvotes, 'downvotes': downvotes};
        });
  }

  Future<VoteType?> getUserVote(String reportId, String userId) async {
    try {
      final response = await _supabase
          .from('votes')
          .select()
          .eq('report_id', reportId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return VoteType.values.firstWhere(
          (e) => e.toString().split('.').last == response['type'],
        );
      }
      return null;
    } catch (e) {
      debugPrint('Get user vote error: $e');
      rethrow;
    }
  }

  Stream<int> getEmergencyReportsCount() {
    return _supabase.from('reports').stream(primaryKey: ['id']).map((data) =>
        data
            .where((report) =>
                report['category'] ==
                    ReportCategory.emergency.toString().split('.').last &&
                report['status'] ==
                    ReportStatus.pending.toString().split('.').last)
            .length);
  }

  Stream<int> getUnreadNotificationsCount(String userId) {
    return _supabase.from('notifications').stream(primaryKey: ['id']).map(
        (data) => data
            .where((notification) =>
                notification['user_id'] == userId &&
                notification['read'] == false)
            .length);
  }

  // Stream to get real-time vote counts for a specific report
  Stream<ReportVotes> getReportVotes(String reportId) {
    return _supabase
        .from('report_votes')
        .stream(primaryKey: ['report_id'])
        .eq('report_id', reportId)
        .map((data) {
          // Ensure data is not empty
          if (data.isEmpty) {
            return ReportVotes(upvotes: 0, downvotes: 0);
          }

          // Aggregate votes
          int upvotes =
              data.where((vote) => vote['vote_type'] == 'upvote').length;
          int downvotes =
              data.where((vote) => vote['vote_type'] == 'downvote').length;

          return ReportVotes(upvotes: upvotes, downvotes: downvotes);
        });
  }

  // Stream to get real-time comment count for a specific report
  Stream<int> getReportCommentCount(String reportId) {
    return _supabase
        .from('comments')
        .stream(primaryKey: ['report_id'])
        .eq('report_id', reportId)
        .map((data) => data.length);
  }

  // Method to handle upvoting a report
  Future<void> upvoteReport(String reportId) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      await _supabase.from('report_votes').upsert({
        'report_id': reportId,
        'user_id': currentUser.id,
        'vote_type': 'upvote'
      });
    } catch (e) {
      print('Error upvoting report: $e');
    }
  }

  // Method to handle downvoting a report
  Future<void> downvoteReport(String reportId) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      await _supabase.from('report_votes').upsert({
        'report_id': reportId,
        'user_id': currentUser.id,
        'vote_type': 'downvote'
      });
    } catch (e) {
      print('Error downvoting report: $e');
    }
  }
}
