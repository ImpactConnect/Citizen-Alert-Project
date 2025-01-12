import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/sos/sos_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/faq/faq_screen.dart';
import '../../screens/more/more_screen.dart';
import 'custom_navigation_bar.dart';

class NavigationScaffold extends StatelessWidget {
  const NavigationScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<NavigationProvider>().currentIndex;

    return WillPopScope(
      onWillPop: () async {
        if (currentIndex != 0) {
          context.read<NavigationProvider>().setIndex(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: const [
            HomeScreen(),
            SOSScreen(),
            SettingsScreen(),
            FAQScreen(),
            MoreScreen(),
          ],
        ),
        bottomNavigationBar: const CustomNavigationBar(),
      ),
    );
  }
}
