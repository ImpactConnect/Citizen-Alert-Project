import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/report_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../reports/report_card.dart';
import '../reports/report_detail_screen.dart';
import '../reports/report_edit_screen.dart';
import '../../widgets/shared/confirmation_dialog.dart';
import '../../services/report_service.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart'
    show RealtimeSubscribeException;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ReportService _reportService = ReportService();
  StreamSubscription? _reportsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeReportsStream();
  }

  @override
  void dispose() {
    _reportsSubscription?.cancel();
    super.dispose();
  }

  void _initializeReportsStream() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _reportsSubscription?.cancel();
      _reportsSubscription =
          _reportService.getReports(userId: user.uid).handleError((error) {
        debugPrint('Reports stream error: $error');
        if (error is RealtimeSubscribeException) {
          // Reconnect after a short delay
          Future.delayed(const Duration(seconds: 1), _initializeReportsStream);
        }
      }).listen((_) {
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _refreshData(BuildContext context) async {
    // Trigger a refresh of the reports stream
    await context.read<ReportProvider>().refreshReports();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit profile screen
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(context),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Header
            _buildProfileHeader(user, theme),
            const SizedBox(height: 24),

            // Stats Section
            _buildStatsSection(context),
            const SizedBox(height: 24),

            // My Reports Section
            _buildMyReportsSection(context, user),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.displayName?[0].toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 32),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName ?? 'User',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              user.email ?? '',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(user.role.toUpperCase()),
              backgroundColor: theme.colorScheme.primaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return StreamBuilder<List<ReportModel>>(
      stream: _reportService.getReports(
          userId: context.read<AuthProvider>().user!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final reports = snapshot.data ?? [];

        // Calculate counts
        final totalReports = reports.length;
        final pendingReports =
            reports.where((r) => r.status == ReportStatus.pending).length;
        final resolvedReports =
            reports.where((r) => r.status == ReportStatus.resolved).length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard(
              context,
              'Total Reports',
              totalReports.toString(),
              Icons.assignment,
            ),
            _buildStatCard(
              context,
              'Pending',
              pendingReports.toString(),
              Icons.pending_actions,
              color: Colors.orange,
            ),
            _buildStatCard(
              context,
              'Resolved',
              resolvedReports.toString(),
              Icons.check_circle_outline,
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.27,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color ?? theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color ?? theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyReportsSection(BuildContext context, UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Reports',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<ReportModel>>(
          stream: _reportService.getReports(userId: user.uid),
          builder: (context, AsyncSnapshot<List<ReportModel>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final reports = snapshot.data ?? [];
            if (reports.isEmpty) {
              return const Center(
                child: Text('You haven\'t submitted any reports yet.'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ReportCard(
                  report: report,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportDetailScreen(report: report),
                      ),
                    );
                  },
                  trailing: report.status == ReportStatus.pending
                      ? PopupMenuButton<String>(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final updated = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ReportEditScreen(report: report),
                                ),
                              );
                              if (updated == true) {
                                // Report was updated, the stream will automatically refresh
                              }
                            } else if (value == 'delete') {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => const ConfirmationDialog(
                                  title: 'Delete Report',
                                  content:
                                      'Are you sure you want to delete this report?',
                                  confirmText: 'Delete',
                                  confirmColor: Colors.red,
                                ),
                              );

                              if (confirmed == true) {
                                try {
                                  await context
                                      .read<ReportProvider>()
                                      .deleteReport(report.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Report deleted successfully'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Error deleting report: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          },
                        )
                      : null,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
