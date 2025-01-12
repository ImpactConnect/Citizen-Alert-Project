import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/report_model.dart';
import '../../../providers/report_provider.dart';
import '../../reports/report_detail_screen.dart';
import 'report_card.dart';

class ReportList extends StatelessWidget {
  const ReportList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReportModel>>(
      // Use ReportService to get reports stream
      stream: context.read<ReportProvider>().getReportsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No reports found')),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final report = reports[index];
              return ReportCard(
                report: report,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportDetailScreen(report: report),
                    ),
                  );
                },
              );
            },
            childCount: reports.length,
          ),
        );
      },
    );
  }
}
