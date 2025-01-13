import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import 'notification_badge.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final bool isGuest = !authProvider.isAuthenticated;

    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 60,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
      ),
      actions: [
        if (!isGuest)
          IconButton(
            icon: const NotificationBadge(),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: user?.avatarUrl != null
                ? Image.network(user!.avatarUrl!, fit: BoxFit.cover)
                : Icon(Icons.person,
                    color: Theme.of(context).colorScheme.onPrimary),
          ),
          itemBuilder: (context) => [
            if (!isGuest) ...[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
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
            ],
            PopupMenuItem<String>(
              value: isGuest ? 'login' : 'logout',
              child: Row(
                children: [
                  Icon(isGuest ? Icons.login : Icons.logout),
                  const SizedBox(width: 8),
                  Text(isGuest ? 'Login' : 'Logout'),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            switch (value) {
              case 'logout':
                await authProvider.signOut();
                break;
              case 'login':
                if (context.mounted) {
                  Navigator.pushNamed(context, '/login');
                }
                break;
              case 'profile':
                if (context.mounted) {
                  Navigator.pushNamed(context, '/profile');
                }
                break;
              case 'settings':
                if (context.mounted) {
                  Navigator.pushNamed(context, '/settings');
                }
                break;
            }
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
