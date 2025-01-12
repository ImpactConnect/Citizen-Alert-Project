import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../reports/report_detail_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final ReportService _reportService = ReportService();

  AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'In Progress'),
              Tab(text: 'Resolved'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildReportList(ReportStatus.pending),
            _buildReportList(ReportStatus.inProgress),
            _buildReportList(ReportStatus.resolved),
            _buildReportList(ReportStatus.rejected),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList(ReportStatus status) {
    return StreamBuilder<List<ReportModel>>(
      stream: _reportService.getReports(status: status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final reports = snapshot.data!;
        if (reports.isEmpty) {
          return Center(
            child: Text('No ${status.toString().split('.').last} reports'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return Card(
              child: ListTile(
                leading: report.mediaUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          report.mediaUrls.first,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.report_problem_outlined),
                      ),
                title: Text(
                  report.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  report.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  report.category.toString().split('.').last,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
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
    );
  }
}
