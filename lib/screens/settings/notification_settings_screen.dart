import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Notification settings state
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _emergencyAlerts = true;
  bool _reportUpdates = true;
  bool _communityAlerts = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _emergencyFrequency = 'always';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'General Notifications',
            children: [
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Enable push notifications'),
                value: _pushEnabled,
                onChanged: (bool value) {
                  setState(() => _pushEnabled = value);
                },
              ),
              SwitchListTile(
                title: const Text('Email Notifications'),
                subtitle: const Text('Receive notifications via email'),
                value: _emailEnabled,
                onChanged: (bool value) {
                  setState(() => _emailEnabled = value);
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Alert Types',
            children: [
              SwitchListTile(
                title: const Text('Emergency Alerts'),
                subtitle: const Text('High-priority emergency notifications'),
                value: _emergencyAlerts,
                onChanged: (bool value) {
                  setState(() => _emergencyAlerts = value);
                },
              ),
              SwitchListTile(
                title: const Text('Report Updates'),
                subtitle: const Text('Updates on your submitted reports'),
                value: _reportUpdates,
                onChanged: (bool value) {
                  setState(() => _reportUpdates = value);
                },
              ),
              SwitchListTile(
                title: const Text('Community Alerts'),
                subtitle: const Text('Alerts from your local community'),
                value: _communityAlerts,
                onChanged: (bool value) {
                  setState(() => _communityAlerts = value);
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Notification Preferences',
            children: [
              SwitchListTile(
                title: const Text('Sound'),
                subtitle: const Text('Play sound for notifications'),
                value: _soundEnabled,
                onChanged: (bool value) {
                  setState(() => _soundEnabled = value);
                },
              ),
              SwitchListTile(
                title: const Text('Vibration'),
                subtitle: const Text('Vibrate for notifications'),
                value: _vibrationEnabled,
                onChanged: (bool value) {
                  setState(() => _vibrationEnabled = value);
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
}
