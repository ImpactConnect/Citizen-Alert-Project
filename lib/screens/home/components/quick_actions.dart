import 'package:flutter/material.dart';
import '../../reports/submit_report_screen.dart';
import '../../explore/explore_screen.dart';
import '../../sos/sos_screen.dart';
import '../../safety/safety_tips_screen.dart';
import '../../analytics/analytics_screen.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _QuickActionButton(
            icon: Icons.add_circle_outline,
            label: 'New Report',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubmitReportScreen()),
            ),
          ),
          _QuickActionButton(
            icon: Icons.explore,
            label: 'Explore',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ExploreScreen()),
            ),
          ),
          _QuickActionButton(
            icon: Icons.warning_amber,
            label: 'SOS',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SOSScreen()),
            ),
          ),
          _QuickActionButton(
            icon: Icons.tips_and_updates,
            label: 'Safety Tips',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SafetyTipsScreen()),
            ),
          ),
          _QuickActionButton(
            icon: Icons.analytics,
            label: 'Analytics',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AnalyticsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
