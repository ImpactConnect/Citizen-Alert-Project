import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/report_service.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<NavigationProvider>().currentIndex;
    final user = context.watch<AuthProvider>().user;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        context.read<NavigationProvider>().setIndex(index);
      },
      animationDuration: const Duration(milliseconds: 300),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
          tooltip: 'Go to Home',
        ),
        NavigationDestination(
          icon: Stack(
            children: [
              const Icon(Icons.warning_outlined),
              if (user != null && !user.isGuest)
                StreamBuilder<int>(
                  stream: ReportService().getEmergencyReportsCount(),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    if (count == 0) return const SizedBox();
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          selectedIcon: const Icon(Icons.warning),
          label: 'SOS',
          tooltip: 'Emergency Reports',
        ),
        const NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
          tooltip: 'App Settings',
        ),
        const NavigationDestination(
          icon: Icon(Icons.help_outline),
          selectedIcon: Icon(Icons.help),
          label: 'FAQ',
          tooltip: 'Frequently Asked Questions',
        ),
        NavigationDestination(
          icon: Stack(
            children: [
              const Icon(Icons.more_horiz),
              if (user != null && !user.isGuest)
                StreamBuilder<int>(
                  stream: ReportService().getUnreadNotificationsCount(user.uid),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    if (count == 0) return const SizedBox();
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          selectedIcon: const Icon(Icons.more_horiz),
          label: 'More',
          tooltip: 'Additional Options',
        ),
      ],
    );
  }
}
