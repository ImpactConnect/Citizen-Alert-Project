import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../screens/reports/submit_report_screen.dart';
import '../../../screens/user_reports/user_reports_screen.dart';
import '../../../screens/analytics/analytics_screen.dart';
import '../../../screens/notifications/notifications_screen.dart';

class NavigationButtons extends StatelessWidget {
  const NavigationButtons({super.key});

  void _showLoginPrompt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please Login to access this feature'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.isAdmin ?? false;
    final isGuest = user?.isGuest ?? false;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _NavButton(
          title: 'Submit Report',
          icon: Icons.add_circle_outline,
          color: Colors.blue,
          onTap: isGuest
              ? () => _showLoginPrompt(context)
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubmitReportScreen(),
                    ),
                  );
                },
        ),
        _NavButton(
          title: 'My Reports',
          icon: Icons.list_alt,
          color: Colors.green,
          onTap: isGuest
              ? () => _showLoginPrompt(context)
              : () {
                  final userId = user?.uid;
                  if (userId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserReportsScreen(userId: userId),
                      ),
                    );
                  }
                },
        ),
        if (isAdmin)
          _NavButton(
            title: 'Analytics',
            icon: Icons.analytics,
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnalyticsScreen(),
                ),
              );
            },
          ),
        if (!isGuest)
          _NavButton(
            title: 'Notifications',
            icon: Icons.notifications,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
