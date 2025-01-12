import 'package:flutter/material.dart';
import '../../../models/report_model.dart';
import '../../../services/report_service.dart';
import '../../reports/report_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class RecentActivity extends StatelessWidget {
  final ReportService _reportService = ReportService();

  RecentActivity({super.key});

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.inProgress:
        return Colors.blue;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        StreamBuilder<List<ReportModel>>(
          stream: _reportService.getReports(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading recent activity'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final reports = snapshot.data!;
            reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final recentReports = reports.take(5).toList();

            if (recentReports.isEmpty) {
              return const Center(child: Text('No recent activity'));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentReports.length,
              itemBuilder: (context, index) {
                final report = recentReports[index];
                final isGuest =
                    context.watch<AuthProvider>().user?.isGuest ?? false;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          _getStatusColor(report.status).withOpacity(0.2),
                      child: Icon(
                        Icons.report_outlined,
                        color: _getStatusColor(report.status),
                      ),
                    ),
                    title: Text(
                      report.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${report.category.toString().split('.').last} • ${_formatDate(report.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(report.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        report.status.toString().split('.').last,
                        style: TextStyle(
                          color: _getStatusColor(report.status),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () {
                      if (isGuest) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please Login to view report details'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportDetailScreen(report: report),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
