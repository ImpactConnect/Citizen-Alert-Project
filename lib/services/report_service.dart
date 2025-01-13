import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_model.dart';
import '../models/comment_model.dart';
import '../models/vote_model.dart';

class ReportService {
  final _supabase = Supabase.instance.client;

  // Create a new report
  Future<void> createReport(ReportModel report) async {
    try {
      await _supabase.from('reports').insert(report.toMap());
    } catch (e) {
      throw 'Failed to create report: $e';
    }
  }

  // Get recent reports
  Future<List<ReportModel>> getRecentReports({int limit = 3}) async {
    try {
      final response = await _supabase
          .from('reports')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((row) => ReportModel.fromMap(row)).toList();
    } catch (e) {
      throw 'Failed to fetch recent reports: $e';
    }
  }

  // Get filtered reports
  Future<List<ReportModel>> getFilteredReports({
    ReportCategory? category,
    ReportStatus? status,
    String? searchQuery,
    String sortBy = 'date',
    bool ascending = false,
  }) async {
    try {
      var query = _supabase.from('reports').select();

      if (category != null) {
        query = query.eq('category', category.toString().split('.').last);
      }

      if (status != null) {
        query = query.eq('status', status.toString().split('.').last);
      }

      String orderColumn = switch (sortBy) {
        'date' => 'created_at',
        'priority' => 'priority',
        'status' => 'status',
        _ => 'created_at',
      };

      final response = await query.order(orderColumn, ascending: ascending);
      var reports =
          (response as List).map((row) => ReportModel.fromMap(row)).toList();

      // Apply text search filter in memory since Supabase text search might be limited
      if (searchQuery != null && searchQuery.isNotEmpty) {
        reports = reports.where((report) {
          return report.title
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              report.description
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
        }).toList();
      }

      return reports;
    } catch (e) {
      throw 'Failed to fetch filtered reports: $e';
    }
  }

  // Update report status
  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    try {
      await _supabase.from('reports').update(
          {'status': status.toString().split('.').last}).eq('id', reportId);
    } catch (e) {
      throw 'Failed to update report status: $e';
    }
  }

  // Add comment to report
  Future<void> addComment(CommentModel comment) async {
    try {
      await _supabase.from('comments').insert(comment.toMap());
    } catch (e) {
      throw 'Failed to add comment: $e';
    }
  }

  // Add vote to report
  Future<void> addVote(VoteModel vote) async {
    try {
      await _supabase.from('votes').insert(vote.toMap());
    } catch (e) {
      throw 'Failed to add vote: $e';
    }
  }

  // Get report comments
  Future<List<CommentModel>> getReportComments(String reportId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select()
          .eq('report_id', reportId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((row) => CommentModel.fromMap(row))
          .toList();
    } catch (e) {
      throw 'Failed to fetch comments: $e';
    }
  }

  // Get report votes
  Future<List<VoteModel>> getReportVotes(String reportId) async {
    try {
      final response =
          await _supabase.from('votes').select().eq('report_id', reportId);

      return (response as List).map((row) => VoteModel.fromMap(row)).toList();
    } catch (e) {
      throw 'Failed to fetch votes: $e';
    }
  }

  // Get all reports with optional user filter
  Stream<List<ReportModel>> getReports({String? userId}) {
    final query = _supabase.from('reports').select();

    if (userId != null) {
      return query
          .filter('user_id', 'eq', userId)
          .order('created_at', ascending: false)
          .asStream()
          .map((data) =>
              (data as List).map((row) => ReportModel.fromMap(row)).toList());
    }

    return query.order('created_at', ascending: false).asStream().map((data) =>
        (data as List).map((row) => ReportModel.fromMap(row)).toList());
  }

  // Get reports once (non-stream)
  Future<List<ReportModel>> getReportsOnce({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    ReportCategory? category,
    ReportStatus? status,
  }) async {
    try {
      var query = _supabase.from('reports').select();

      if (userId != null) {
        query = query.filter('user_id', 'eq', userId);
      }

      if (category != null) {
        query =
            query.filter('category', 'eq', category.toString().split('.').last);
      }

      if (status != null) {
        query = query.filter('status', 'eq', status.toString().split('.').last);
      }

      if (startDate != null) {
        query = query.filter('created_at', 'gte', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.filter('created_at', 'lte', endDate.toIso8601String());
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List).map((row) => ReportModel.fromMap(row)).toList();
    } catch (e) {
      throw 'Failed to fetch reports: $e';
    }
  }

  // Update existing report
  Future<void> updateReport(ReportModel report) async {
    try {
      await _supabase
          .from('reports')
          .update(report.toMap())
          .eq('id', report.id);
    } catch (e) {
      throw 'Failed to update report: $e';
    }
  }

  // Delete report
  Future<void> deleteReport(String reportId) async {
    try {
      await _supabase.from('reports').delete().eq('id', reportId);
    } catch (e) {
      throw 'Failed to delete report: $e';
    }
  }

  // Get comments for a report
  Stream<List<CommentModel>> getComments(String reportId) {
    return _supabase
        .from('comments')
        .select()
        .filter('report_id', 'eq', reportId)
        .order('created_at')
        .asStream()
        .map((data) =>
            (data as List).map((row) => CommentModel.fromMap(row)).toList());
  }

  // Delete comment
  Future<void> deleteComment(String commentId) async {
    try {
      await _supabase.from('comments').delete().eq('id', commentId);
    } catch (e) {
      throw 'Failed to delete comment: $e';
    }
  }

  // Get emergency reports count
  Stream<int> getEmergencyReportsCount() {
    return _supabase
        .from('reports')
        .select()
        .filter('category', 'eq', 'emergency')
        .filter('status', 'eq', 'pending')
        .asStream()
        .map((data) => (data as List).length);
  }

  // Get unread notifications count
  Stream<int> getUnreadNotificationsCount(String userId) {
    return _supabase
        .from('notifications')
        .select()
        .filter('user_id', 'eq', userId)
        .filter('read', 'eq', false)
        .asStream()
        .map((data) => (data as List).length);
  }
}
