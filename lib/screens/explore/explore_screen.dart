import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/report_model.dart';
import '../../models/report_votes.dart';
import '../../services/report_service.dart';
import '../reports/report_detail_screen.dart';
import '../../providers/auth_provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  ReportCategory? _selectedCategory;
  ReportStatus? _selectedStatus;
  List<ReportModel> _allReports = [];
  List<ReportModel> _filteredReports = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final reportService = ReportService();
      final reports = await reportService.getReports().first;
      setState(() {
        _allReports = reports;
        _filteredReports = reports;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching reports: $e')),
      );
    }
  }

  void _filterReports() {
    setState(() {
      _filteredReports = _allReports.where((report) {
        // Search by title
        final titleMatch = _searchController.text.isEmpty ||
            report.title
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        // Filter by category
        final categoryMatch =
            _selectedCategory == null || report.category == _selectedCategory;

        // Filter by status
        final statusMatch =
            _selectedStatus == null || report.status == _selectedStatus;

        return titleMatch && categoryMatch && statusMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text('Community Reports'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search reports...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterReports();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (_) => _filterReports(),
            ),
          ),

          // Filters Label and Scrollview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                const Expanded(child: Divider()),
              ],
            ),
          ),

          // Horizontal Filter Scrollview
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // Category Filter Dropdown
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: DropdownButton<ReportCategory>(
                    hint: Text(
                      'Category',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value: _selectedCategory,
                    underline: Container(),
                    icon: const Icon(Icons.filter_list),
                    items: ReportCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (category) {
                      setState(() {
                        _selectedCategory = category;
                        _filterReports();
                      });
                    },
                  ),
                ),

                // Status Filter Dropdown
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: DropdownButton<ReportStatus>(
                    hint: Text(
                      'Status',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value: _selectedStatus,
                    underline: Container(),
                    icon: const Icon(Icons.filter_list),
                    items: ReportStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (status) {
                      setState(() {
                        _selectedStatus = status;
                        _filterReports();
                      });
                    },
                  ),
                ),

                // Clear Filters Button
                if (_selectedCategory != null || _selectedStatus != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Filters'),
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedStatus = null;
                        _searchController.clear();
                        _filteredReports = _allReports;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
              ],
            ),
          ),

          // Active Filters Display
          if (_selectedCategory != null || _selectedStatus != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedCategory != null)
                    Chip(
                      label: Text(
                        'Category: ${_selectedCategory.toString().split('.').last}',
                      ),
                      onDeleted: () {
                        setState(() {
                          _selectedCategory = null;
                          _filterReports();
                        });
                      },
                    ),
                  if (_selectedStatus != null)
                    Chip(
                      label: Text(
                        'Status: ${_selectedStatus.toString().split('.').last}',
                      ),
                      onDeleted: () {
                        setState(() {
                          _selectedStatus = null;
                          _filterReports();
                        });
                      },
                    ),
                ],
              ),
            ),

          // Reports List
          Expanded(
            child: _filteredReports.isEmpty
                ? const Center(
                    child: Text(
                      'No reports found',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchReports,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredReports.length,
                      itemBuilder: (context, index) {
                        return _ReportCard(report: _filteredReports[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ReportCard extends StatefulWidget {
  final ReportModel report;

  const _ReportCard({required this.report});

  @override
  __ReportCardState createState() => __ReportCardState();
}

class __ReportCardState extends State<_ReportCard> {
  int _upvotes = 0;
  int _downvotes = 0;
  int _commentCount = 0;
  bool _showFullDetails = false;

  @override
  void initState() {
    super.initState();
    _fetchVotesAndComments();
  }

  Future<void> _fetchVotesAndComments() async {
    try {
      final reportService = ReportService();

      // Fetch vote counts
      final voteStream = reportService.getReportVotes(widget.report.id);
      voteStream.listen((votes) {
        setState(() {
          _upvotes = votes.upvotes;
          _downvotes = votes.downvotes;
        });
      });

      // Fetch comment count
      final commentStream =
          reportService.getReportCommentCount(widget.report.id);
      commentStream.listen((count) {
        setState(() {
          _commentCount = count;
        });
      });
    } catch (e) {
      print('Error fetching report interactions: $e');
    }
  }

  void _handleUpvote() {
    final reportService = ReportService();
    reportService.upvoteReport(widget.report.id);
  }

  void _handleDownvote() {
    final reportService = ReportService();
    reportService.downvoteReport(widget.report.id);
  }

  IconData _getCategoryIcon(ReportCategory category) {
    final categoryName = category.toString().split('.').last.toLowerCase();

    final categoryIcons = {
      'infrastructure': Icons.construction,
      'environment': Icons.eco,
      'safety': Icons.security,
      'health': Icons.medical_services,
      'transportation': Icons.directions_bus,
      'utilities': Icons.electrical_services,
      'other': Icons.category,
    };

    return categoryIcons[categoryName] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportDetailScreen(report: widget.report),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Title
              Text(
                widget.report.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Report Metadata Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category Chip
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(widget.report.category),
                        size: 18,
                        color: theme.colorScheme.primary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.report.category
                            .toString()
                            .split('.')
                            .last
                            .toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),

                  // Status Chip
                  Chip(
                    label: Text(
                      widget.report.status.toString().split('.').last,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(widget.report.status, theme),
                      ),
                    ),
                    backgroundColor:
                        _getStatusColor(widget.report.status, theme)
                            .withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Expandable Description
              if (_showFullDetails)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    widget.report.description,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Additional Metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Time Posted
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimePosted(widget.report.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),

                  // Votes and Comments
                  Row(
                    children: [
                      // Upvote/Downvote Section
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_upward,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              onPressed: _handleUpvote,
                            ),
                            Text(
                              '${_upvotes - _downvotes}',
                              style: theme.textTheme.bodySmall,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_downward,
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                              onPressed: _handleDownvote,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Comments
                      Row(
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 16,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_commentCount',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // Show/Hide Details Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showFullDetails = !_showFullDetails;
                      });
                    },
                    child: Text(
                      _showFullDetails ? 'Hide Details' : 'Show Details',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ReportStatus status, ThemeData theme) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.inProgress:
        return Colors.blue;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
      default:
        return theme.colorScheme.outline;
    }
  }

  String _formatTimePosted(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
