import 'package:flutter/material.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/messaging/presentation/pages/messaging_page.dart';
import '../../features/relationships/presentation/pages/relationships_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../theme/app_colors.dart';

/// Main navigation shell with Material 3 NavigationBar.
/// Adheres strictly to AGENTS.md styling and dark theme tokens.
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
        : (user?.isAnonymous == true ? 'Guest Explorer' : (user?.email?.split('@').first ?? 'Friend'));

    final screens = [
      DashboardPage(
        displayName: displayName,
        authController: widget.authController,
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
      RelationshipsPage(userId: user?.id),
      MessagingPage(currentUserId: user?.id),
      UsersPage(authController: widget.authController),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      // AGENTS.md Rule 3: Bottom Navigation Bar with dark theme surface and 1px border
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: AppColors.microLabel),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded, color: AppColors.microLabel),
              selectedIcon: Icon(Icons.people_rounded, color: AppColors.primary),
              label: 'Relationships',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded, color: AppColors.microLabel),
              selectedIcon: Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: AppColors.microLabel),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
