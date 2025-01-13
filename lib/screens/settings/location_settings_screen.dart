import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  bool _locationEnabled = false;
  bool _preciseLocation = true;
  bool _backgroundLocation = false;
  String _selectedAccuracy = 'high';
  LocationPermission? _permission;

  @override
  void initState() {
    super.initState();
    _checkLocationSettings();
  }

  Future<void> _checkLocationSettings() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();

    setState(() {
      _locationEnabled = serviceEnabled;
      _permission = permission;
    });
  }

  Future<void> _requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    setState(() => _permission = permission);
  }

  Future<void> _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> _saveLocationSettings() async {
    // TODO: Save location settings to backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Settings'),
        actions: [
          TextButton(
            onPressed: _saveLocationSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Location Services',
            children: [
              ListTile(
                title: const Text('Location Services'),
                subtitle: Text(_locationEnabled ? 'Enabled' : 'Disabled'),
                trailing: ElevatedButton(
                  onPressed: _openLocationSettings,
                  child: Text(_locationEnabled ? 'Configure' : 'Enable'),
                ),
              ),
              ListTile(
                title: const Text('Location Permission'),
                subtitle: Text(_getPermissionText()),
                trailing: ElevatedButton(
                  onPressed: _requestLocationPermission,
                  child: const Text('Request'),
                ),
              ),
            ],
          ),
          _buildSection(
            title: 'Location Settings',
            children: [
              SwitchListTile(
                title: const Text('Precise Location'),
                subtitle:
                    const Text('Use precise location for better accuracy'),
                value: _preciseLocation,
                onChanged: (bool value) {
                  setState(() => _preciseLocation = value);
                },
              ),
              SwitchListTile(
                title: const Text('Background Location'),
                subtitle: const Text(
                    'Allow location access while app is in background'),
                value: _backgroundLocation,
                onChanged: (bool value) {
                  setState(() => _backgroundLocation = value);
                },
              ),
              ListTile(
                title: const Text('Location Accuracy'),
                subtitle: const Text('Set desired location accuracy'),
                trailing: DropdownButton<String>(
                  value: _selectedAccuracy,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedAccuracy = newValue);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'high',
                      child: Text('High Accuracy'),
                    ),
                    DropdownMenuItem(
                      value: 'balanced',
                      child: Text('Balanced'),
                    ),
                    DropdownMenuItem(
                      value: 'low',
                      child: Text('Low Power'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildSection(
            title: 'Location History',
            children: [
              ListTile(
                title: const Text('View Location History'),
                subtitle: const Text('See where you\'ve been'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to location history screen
                },
              ),
              ListTile(
                title: const Text('Clear Location History'),
                subtitle: const Text('Delete all stored location data'),
                trailing: const Icon(Icons.delete_forever),
                onTap: () => _showClearHistoryDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPermissionText() {
    switch (_permission) {
      case LocationPermission.always:
        return 'Always';
      case LocationPermission.whileInUse:
        return 'While Using';
      case LocationPermission.denied:
        return 'Denied';
      case LocationPermission.deniedForever:
        return 'Denied Forever';
      default:
        return 'Unknown';
    }
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

  Future<void> _showClearHistoryDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Location History'),
        content: const Text(
          'Are you sure you want to clear your location history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement history clearing
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location history cleared'),
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
