import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  final _reportService = ReportService();
  List<ReportModel> _reports = [];
  String _searchQuery = '';
  ReportCategory? _selectedCategory;
  ReportStatus? _selectedStatus;
  bool _isLoading = false;
  String? _error;
  DateTime? _startDate;
  DateTime? _endDate;

  List<ReportModel> get reports => _filterReports();
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  ReportCategory? get selectedCategory => _selectedCategory;
  ReportStatus? get selectedStatus => _selectedStatus;
  String? get error => _error;

  Stream<List<ReportModel>> getReportsStream() {
    return _reportService.getReports().map((reports) {
      _reports = reports;
      return _filterReports();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  void setCategory(ReportCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setStatus(ReportStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  List<ReportModel> _filterReports() {
    var filteredReports = List<ReportModel>.from(_reports);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredReports = filteredReports.where((report) {
        final title = report.title.toLowerCase();
        final description = report.description.toLowerCase();
        final location = report.location.toLowerCase();
        return title.contains(_searchQuery) ||
            description.contains(_searchQuery) ||
            location.contains(_searchQuery);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filteredReports = filteredReports
          .where((report) => report.category == _selectedCategory)
          .toList();
    }

    // Apply status filter
    if (_selectedStatus != null) {
      filteredReports = filteredReports
          .where((report) => report.status == _selectedStatus)
          .toList();
    }

    return filteredReports;
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedStatus = null;
    notifyListeners();
  }

  Future<void> deleteReport(String reportId) async {
    try {
      await _reportService.deleteReport(reportId);
      await refreshReports();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshReports() async {
    try {
      _isLoading = true;
      notifyListeners();

      final reports = await _reportService.getReportsOnce(
        category: _selectedCategory,
        status: _selectedStatus,
      );
      _reports = reports;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ReportModel>> getFilteredReports() async {
    try {
      return await _reportService.getReportsOnce(
        category: _selectedCategory,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
      );
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
}
