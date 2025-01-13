import 'package:flutter/material.dart';
import '../../widgets/layout/base_layout.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Safety Tips',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTipCard(
            context,
            title: 'Emergency Contacts',
            content: 'Save important emergency numbers in your phone:\n'
                '• Police: 112\n'
                '• Ambulance: 112\n'
                '• Fire Service: 112',
            icon: Icons.emergency,
          ),
          _buildTipCard(
            context,
            title: 'Report Safely',
            content: 'When reporting an incident:\n'
                '• Stay at a safe distance\n'
                '• Don\'t put yourself in danger\n'
                '• Take photos only if safe to do so',
            icon: Icons.security,
          ),
          _buildTipCard(
            context,
            title: 'Location Sharing',
            content:
                'Share your location with trusted contacts during emergencies.',
            icon: Icons.location_on,
          ),
          _buildTipCard(
            context,
            title: 'Be Prepared',
            content: 'Keep an emergency kit ready with:\n'
                '• First aid supplies\n'
                '• Flashlight\n'
                '• Battery bank\n'
                '• Important documents',
            icon: Icons.medical_services,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
