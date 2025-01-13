import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/report_service.dart';
import '../../models/report_model.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen>
    with SingleTickerProviderStateMixin {
  bool _isActivating = false;
  final _reportService = ReportService();
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _sendSOSSignal();
          setState(() => _isActivating = false);
        }
      });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

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

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied';
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _sendSOSSignal() async {
    try {
      final position = await _getCurrentLocation();
      final user = context.read<AuthProvider>().user;
      final reportId = const Uuid().v4();

      final report = ReportModel(
        id: reportId,
        userId: user?.uid ?? 'guest',
        title: 'EMERGENCY SOS SIGNAL',
        description: 'Emergency distress signal activated',
        location: '${position.latitude}, ${position.longitude}',
        category: ReportCategory.emergency,
        status: ReportStatus.pending,
        priority: 'high',
        createdAt: DateTime.now(),
        mediaUrls: [],
        videoUrl: null,
      );

      await _reportService.createReport(report);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Emergency signal sent! Help is on the way.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error sending SOS signal: $e',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
          // SOS Button
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: GestureDetector(
                onLongPressStart: (_) {
                  setState(() => _isActivating = true);
                  HapticFeedback.heavyImpact();
                  _progressController.forward(from: 0.0);
                },
                onLongPressEnd: (_) {
                  if (_progressController.value < 1.0) {
                    _progressController.reset();
                    setState(() => _isActivating = false);
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isActivating ? 120 : 100,
                      height: _isActivating ? 120 : 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isActivating ? Colors.red[700] : Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            spreadRadius: _isActivating ? 10 : 2,
                            blurRadius: _isActivating ? 15 : 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: Colors.white,
                              size: _isActivating ? 48 : 40,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _isActivating ? 20 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isActivating)
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: _progressController.value,
                              strokeWidth: 4,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          const Text(
            'Hold the SOS button for 3 seconds to send an emergency signal',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
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
