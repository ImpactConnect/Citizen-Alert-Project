import 'package:flutter/material.dart';
import '../../../models/report_model.dart';
import '../../../services/report_service.dart';

class MetricsSummary extends StatelessWidget {
  final ReportService _reportService = ReportService();

  MetricsSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReportModel>>(
      stream: _reportService.getReports(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading metrics'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data!;
        final totalReports = reports.length;
        final pendingReports =
            reports.where((r) => r.status == ReportStatus.pending).length;
        final inProgressReports =
            reports.where((r) => r.status == ReportStatus.inProgress).length;
        final resolvedReports =
            reports.where((r) => r.status == ReportStatus.resolved).length;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _MetricCard(
              title: 'Total Reports',
              value: totalReports.toString(),
              icon: Icons.assessment,
              color: Colors.blue,
            ),
            _MetricCard(
              title: 'Pending',
              value: pendingReports.toString(),
              icon: Icons.pending_actions,
              color: Colors.orange,
            ),
            _MetricCard(
              title: 'In Progress',
              value: inProgressReports.toString(),
              icon: Icons.trending_up,
              color: Colors.purple,
            ),
            _MetricCard(
              title: 'Resolved',
              value: resolvedReports.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
