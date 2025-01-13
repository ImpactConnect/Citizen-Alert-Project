import 'package:flutter/material.dart';
import '../navigation/custom_navigation_bar.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const BaseLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: actions ??
            [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: user?.avatarUrl != null
                      ? Image.network(user!.avatarUrl!)
                      : const Icon(Icons.person, color: Colors.white),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      Navigator.pushNamed(context, '/profile');
                      break;
                    case 'settings':
                      Navigator.pushNamed(context, '/settings');
                      break;
                    case 'logout':
                      context.read<AuthProvider>().signOut();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline),
                        SizedBox(width: 8),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined),
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
      ),
      body: child,
      bottomNavigationBar: const CustomNavigationBar(),
      floatingActionButton: floatingActionButton,
    );
  }
}
