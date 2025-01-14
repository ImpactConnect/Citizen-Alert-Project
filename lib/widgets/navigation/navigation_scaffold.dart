import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/explore/explore_screen.dart';
import '../../screens/sos/sos_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/faq/faq_screen.dart';
import '../../screens/more/more_screen.dart';
import 'custom_navigation_bar.dart';

class NavigationScaffold extends StatelessWidget {
  final int? initialIndex;
  final Widget? child;

  const NavigationScaffold({
    super.key,
    this.initialIndex,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    // Set initial index if provided
    if (initialIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationProvider.setIndex(initialIndex!);
      });
    }

    return Scaffold(
      body: child ??
          IndexedStack(
            index: navigationProvider.currentIndex,
            children: [
              HomeScreen(),
              ExploreScreen(),
              const SOSScreen(),
              const SettingsScreen(),
              const FAQScreen(),
              const MoreScreen(),
            ],
          ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}
