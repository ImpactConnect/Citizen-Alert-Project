import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../reports/report_detail_screen.dart';

class ExploreScreen extends StatelessWidget {
  final ReportService _reportService = ReportService();

  ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Reports'),
      ),
      body: StreamBuilder<List<ReportModel>>(
        stream: _reportService.getReports(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Icon(
                    _getCategoryIcon(report.category),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(report.title),
                  subtitle: Text(
                    report.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Chip(
                    label: Text(report.status.toString().split('.').last),
                    backgroundColor:
                        _getStatusColor(report.status).withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: _getStatusColor(report.status),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportDetailScreen(report: report),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(ReportCategory category) {
    switch (category) {
      case ReportCategory.infrastructure:
        return Icons.build;
      case ReportCategory.environment:
        return Icons.nature;
      case ReportCategory.utilities:
        return Icons.power;
      case ReportCategory.emergency:
        return Icons.emergency;
      case ReportCategory.general:
        return Icons.info;
    }
  }

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
}
