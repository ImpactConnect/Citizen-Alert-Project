import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../widgets/layout/base_layout.dart';

class AnalyticsScreen extends StatelessWidget {
  final ReportService _reportService = ReportService();

  AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Analytics',
      child: StreamBuilder<List<ReportModel>>(
        stream: _reportService.getReports(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!;
          final totalReports = reports.length;
          final Map<ReportCategory, int> categoryCount = {};
          final Map<ReportStatus, int> statusCount = {};

          for (var report in reports) {
            categoryCount[report.category] =
                (categoryCount[report.category] ?? 0) + 1;
            statusCount[report.status] = (statusCount[report.status] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Reports: $totalReports',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Text(
                  'Reports by Category',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...categoryCount.entries.map((entry) => ListTile(
                      title: Text(entry.key.toString().split('.').last),
                      trailing: Text(
                        entry.value.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )),
                const SizedBox(height: 24),
                Text(
                  'Reports by Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...statusCount.entries.map((entry) => ListTile(
                      title: Text(entry.key.toString().split('.').last),
                      trailing: Text(
                        entry.value.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
