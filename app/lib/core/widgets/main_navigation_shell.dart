import 'package:flutter/material.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/messaging/presentation/pages/messaging_page.dart';
import '../../features/relationships/presentation/pages/relationships_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../theme/app_colors.dart';

/// Main navigation shell with Material 3 NavigationBar.
class MainNavigationShell extends StatefulWidget {
  final AuthController authController;

  const MainNavigationShell({super.key, required this.authController});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = widget.authController.currentUser;
    final displayName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : (user?.isAnonymous == true ? 'Guest User' : (user?.email?.split('@').first ?? 'Friend'));

    final screens = [
      _DashboardView(
        displayName: displayName,
        authController: widget.authController,
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
      RelationshipsPage(userId: user?.id),
      const MessagingPage(),
      UsersPage(authController: widget.authController),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded, color: AppColors.primary),
            label: 'Relationships',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Home dashboard tab
class _DashboardView extends StatelessWidget {
  final String displayName;
  final AuthController authController;
  final void Function(int) onNavigate;

  const _DashboardView({
    required this.displayName,
    required this.authController,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bondly', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => authController.signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Greeting Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(80),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withAlpha(50),
                      child: Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'B',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $displayName 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Nurture your meaningful connections today',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Privacy Assurance Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: Colors.green, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Owner-Only Privacy: Your contact notes, logs, and follow-ups are encrypted and visible only to you.',
                    style: TextStyle(
                      color: Color(0xFF1B5E20),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Navigation Grid
          const Text(
            'Explore Modules',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.4,
            children: [
              _ModuleQuickCard(
                icon: Icons.favorite_border_rounded,
                title: 'Relationships',
                subtitle: 'Private contacts & logs',
                color: const Color(0xFFE91E63),
                onTap: () => onNavigate(1),
              ),
              _ModuleQuickCard(
                icon: Icons.alarm_rounded,
                title: 'Follow-ups',
                subtitle: 'Reminders & cadence',
                color: const Color(0xFF3F51B5),
                onTap: () => onNavigate(1),
              ),
              _ModuleQuickCard(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Messaging',
                subtitle: 'Direct conversations',
                color: const Color(0xFF009688),
                onTap: () => onNavigate(2),
              ),
              _ModuleQuickCard(
                icon: Icons.person_outline_rounded,
                title: 'Profile & Privacy',
                subtitle: 'Data & account settings',
                color: const Color(0xFFFF9800),
                onTap: () => onNavigate(3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleQuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ModuleQuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withAlpha(25),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
