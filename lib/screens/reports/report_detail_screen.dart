import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/report_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/report_service.dart';
import '../../widgets/admin/admin_comment_dialog.dart';
import '../../screens/reports/report_edit_screen.dart';
import '../../widgets/shared/confirmation_dialog.dart';
import '../../widgets/reports/comments_section.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;
  final ReportService _reportService = ReportService();

  ReportDetailScreen({
    super.key,
    required this.report,
  });

  String _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return '#FFA000'; // Amber
      case ReportStatus.inProgress:
        return '#1976D2'; // Blue
      case ReportStatus.resolved:
        return '#388E3C'; // Green
      case ReportStatus.rejected:
        return '#D32F2F'; // Red
    }
  }

  void _showAdminCommentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AdminCommentDialog(
        initialComment: '',
        onSubmit: (comment) async {
          try {
            await _reportService.updateReportStatus(
              report.id,
              report.status,
              adminComment: comment,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Comment updated successfully')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Error updating comment: ${e.toString()}')),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteReport(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Delete Report',
        content:
            'Are you sure you want to delete this report? This action cannot be undone.',
        confirmText: 'Delete',
        confirmColor: Colors.red,
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await _reportService.deleteReport(report.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report deleted successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting report: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _updateStatus(
      BuildContext context, ReportStatus newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Update Status',
        content:
            'Are you sure you want to mark this report as ${newStatus.toString().split('.').last}?',
        confirmText: 'Update',
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await _reportService.updateReportStatus(report.id, newStatus);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status updated successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating status: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.user?.role == 'admin';
    final isOwner = authProvider.user?.uid == report.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        actions: [
          if (isOwner && report.status == ReportStatus.pending) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportEditScreen(report: report),
                  ),
                );
                if (updated == true && context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () => _deleteReport(context),
            ),
          ],
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.comment),
              onPressed: () => _showAdminCommentDialog(context),
            ),
            PopupMenuButton<ReportStatus>(
              onSelected: (status) => _updateStatus(context, status),
              itemBuilder: (BuildContext context) {
                return ReportStatus.values.map((ReportStatus status) {
                  return PopupMenuItem<ReportStatus>(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }).toList();
              },
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(
                  int.parse(
                    _getStatusColor(report.status).replaceAll('#', '0xFF'),
                  ),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                report.status.toString().split('.').last,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              report.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),

            // Category and Date
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  report.category.toString().split('.').last,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location if available
            if (report.location != null && report.location!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      report.location!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(report.description),
            const SizedBox(height: 24),

            // Media
            if (report.mediaUrls.isNotEmpty) ...[
              const Text(
                'Media',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: report.mediaUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Show full-screen media viewer
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            report.mediaUrls[index],
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (!context.watch<AuthProvider>().user!.isGuest) ...[
              const Divider(height: 32),
              CommentsSection(reportId: report.id),
            ],
          ],
        ),
      ),
    );
  }
}
