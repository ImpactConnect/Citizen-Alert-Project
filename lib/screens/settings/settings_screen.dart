import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Settings
          _buildSection(
            title: 'Account',
            children: [
              _buildTile(
                title: 'Profile Settings',
                icon: Icons.person_outline,
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              _buildTile(
                title: 'Notification Preferences',
                icon: Icons.notifications_outlined,
                onTap: () {
                  // TODO: Implement notification settings
                },
              ),
              _buildTile(
                title: 'Privacy Settings',
                icon: Icons.privacy_tip_outlined,
                onTap: () {
                  // TODO: Implement privacy settings
                },
              ),
            ],
          ),

          // App Settings
          _buildSection(
            title: 'App Settings',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (bool value) {
                  // TODO: Implement theme switching
                },
              ),
              _buildTile(
                title: 'Language',
                icon: Icons.language_outlined,
                trailing: const Text('English'),
                onTap: () {
                  // TODO: Implement language selection
                },
              ),
              _buildTile(
                title: 'Location Settings',
                icon: Icons.location_on_outlined,
                onTap: () {
                  // TODO: Implement location settings
                },
              ),
            ],
          ),

          // Data & Storage
          _buildSection(
            title: 'Data & Storage',
            children: [
              _buildTile(
                title: 'Clear Cache',
                icon: Icons.cleaning_services_outlined,
                onTap: () {
                  // TODO: Implement cache clearing
                },
              ),
              _buildTile(
                title: 'Download Reports',
                icon: Icons.download_outlined,
                onTap: () {
                  // TODO: Implement report downloading
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.data_saver_off_outlined),
                title: const Text('Data Saver'),
                subtitle: const Text('Reduce data usage'),
                value: false,
                onChanged: (bool value) {
                  // TODO: Implement data saver
                },
              ),
            ],
          ),

          // Support & About
          _buildSection(
            title: 'Support & About',
            children: [
              _buildTile(
                title: 'Help Center',
                icon: Icons.help_outline,
                onTap: () {
                  // TODO: Implement help center
                },
              ),
              _buildTile(
                title: 'Report a Problem',
                icon: Icons.bug_report_outlined,
                onTap: () {
                  // TODO: Implement problem reporting
                },
              ),
              _buildTile(
                title: 'Share App',
                icon: Icons.share_outlined,
                onTap: () {
                  Share.share(
                    'Check out Citizen Alert - Report incidents and stay informed!',
                  );
                },
              ),
              _buildTile(
                title: 'Privacy Policy',
                icon: Icons.policy_outlined,
                onTap: () async {
                  const url = 'https://your-privacy-policy-url.com';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  }
                },
              ),
              _buildTile(
                title: 'Terms of Service',
                icon: Icons.description_outlined,
                onTap: () async {
                  const url = 'https://your-terms-of-service-url.com';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  }
                },
              ),
              _buildTile(
                title: 'App Version',
                icon: Icons.info_outline,
                trailing: const Text('1.0.0'),
                onTap: null,
              ),
            ],
          ),

          // Account Actions
          _buildSection(
            title: 'Account Actions',
            children: [
              _buildTile(
                title: 'Sign Out',
                icon: Icons.logout,
                textColor: Colors.red,
                onTap: () {
                  context.read<AuthProvider>().signOut();
                },
              ),
              if (!user!.isGuest)
                _buildTile(
                  title: 'Delete Account',
                  icon: Icons.delete_forever_outlined,
                  textColor: Colors.red,
                  onTap: () {
                    _showDeleteAccountDialog(context);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildTile({
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
