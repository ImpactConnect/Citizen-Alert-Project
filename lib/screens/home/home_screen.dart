import 'package:flutter/material.dart';
import 'components/welcome_banner.dart';
import 'components/quick_actions.dart';
import 'components/recent_reports.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
        },
        child: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: WelcomeBanner(),
            ),
            SizedBox(height: 24),
            QuickActions(),
            SizedBox(height: 24),
            RecentReports(),
            // More sections will be added here
          ],
        ),
      ),
    );
  }
}
