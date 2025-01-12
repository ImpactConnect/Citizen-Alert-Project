import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/navigation/custom_navigation_bar.dart';

class SOSScreen extends StatelessWidget {
  const SOSScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phone number copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildEmergencyCard(
            title: 'National Emergency Number',
            contacts: const ['112'],
            icon: Icons.emergency,
            color: Colors.red,
          ),
          _buildStateSection(context),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard({
    required String title,
    required List<String> contacts,
    required IconData icon,
    required Color color,
    String? description,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...contacts.map((contact) => _buildContactTile(contact)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(String phoneNumber) {
    return Builder(
      builder: (context) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          phoneNumber,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copyToClipboard(context, phoneNumber),
              tooltip: 'Copy number',
            ),
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: () => _makePhoneCall(phoneNumber),
              tooltip: 'Call number',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateSection(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Lagos State Emergency Contacts',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        _buildEmergencyCard(
          title: 'Police',
          contacts: const ['112', '767', '08039003913'],
          icon: Icons.local_police,
          color: Colors.blue,
          description: 'Lagos State Police Command',
        ),
        _buildEmergencyCard(
          title: 'Fire Service',
          contacts: const ['112', '01-7944996', '080-33235892'],
          icon: Icons.local_fire_department,
          color: Colors.orange,
          description: 'Lagos State Fire Service',
        ),
        _buildEmergencyCard(
          title: 'FRSC',
          contacts: const ['122', '0700-CALL-FRSC', '08077690362'],
          icon: Icons.car_crash,
          color: Colors.green,
          description: 'Federal Road Safety Corps',
        ),
        _buildEmergencyCard(
          title: 'NSCDC',
          contacts: const ['112', '08060003972', '08057767233'],
          icon: Icons.security,
          color: Colors.purple,
          description: 'Nigeria Security and Civil Defence Corps',
        ),
        _buildEmergencyCard(
          title: 'LASEMA',
          contacts: const ['112', '767', '08060907333'],
          icon: Icons.health_and_safety,
          color: Colors.red,
          description: 'Lagos State Emergency Management Agency',
        ),
        _buildEmergencyCard(
          title: 'LASTMA',
          contacts: const ['08129928515', '08129928503', '08129928597'],
          icon: Icons.traffic,
          color: Colors.amber,
          description: 'Lagos State Traffic Management Authority',
        ),
      ],
    );
  }
}
