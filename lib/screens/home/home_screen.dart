import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'components/home_app_bar.dart';
import 'components/report_list.dart';
import 'components/filter_section.dart';
import '../reports/submit_report_screen.dart';
import '../../providers/report_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _refreshData(BuildContext context) async {
    // Trigger a refresh of the reports stream
    await context.read<ReportProvider>().refreshReports();
  }

  void _showLoginPrompt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Please login to create a report'),
            TextButton(
              onPressed: () {
                // Navigate to login screen
                Navigator.pushNamed(context, '/login');
              },
              child: const Text(
                'Login',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<AuthProvider>().user?.isGuest ?? true;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _refreshData(context),
        child: CustomScrollView(
          slivers: [
            const HomeAppBar(),
            const FilterSection(),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Recent Reports',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const ReportList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isGuest) {
            _showLoginPrompt(context);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SubmitReportScreen(),
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Report'),
      ),
    );
  }
}
