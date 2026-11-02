import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../connections/presentation/pages/connections_page.dart';
import '../../../followups/presentation/pages/followups_page.dart';
import '../../../goals/presentation/pages/goals_page.dart';
import '../../../groups/presentation/pages/groups_page.dart';
import '../../../insights/presentation/pages/insights_page.dart';
import '../../../invitations/presentation/pages/invitations_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../privacy/presentation/pages/privacy_page.dart';
import '../widgets/dashboard_widget.dart';

/// Feature: Dashboard - Main Overview Page
/// Adheres strictly to AGENTS.md design tokens, layout patterns, and privacy standards.
class DashboardPage extends StatelessWidget {
  final AuthController authController;
  final String? displayName;
  final void Function(int index)? onNavigate;

  const DashboardPage({
    super.key,
    required this.authController,
    this.displayName,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser;
    final effectiveName = displayName?.isNotEmpty == true
        ? displayName!
        : (user?.displayName?.isNotEmpty == true
            ? user!.displayName!
            : (user?.isAnonymous == true
                ? 'Guest Explorer'
                : (user?.email?.split('@').first ?? 'Friend')));

    final userId = user?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Bondly',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationsPage(currentUserId: userId),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Connections',
            icon: const Icon(Icons.people_outline_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConnectionsPage(
                  currentUserId: userId,
                  currentUserName: effectiveName,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            onPressed: () => authController.signOut(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // AGENTS.md Rule 1: Always handle vertical scrollability
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Greeting Banner (Coral Accent)
            DashboardGreetingBanner(displayName: effectiveName),
            const SizedBox(height: 18),

            // 2. Owner-Only Privacy Status Banner (Muted Violet)
            PrivacyStatusBanner(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrivacyPage(currentUserId: userId),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Section Title
            const Text(
              'Explore Modules',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),

            // 4. Safe 2-Column Module Grid (childAspectRatio: 1.18 prevents RenderFlex overflow)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.18,
              children: [
                DashboardModuleCard(
                  icon: Icons.favorite_rounded,
                  title: 'Relationships',
                  subtitle: 'Private contacts & logs',
                  accentColor: const Color(0xFFFF6B50),
                  onTap: () {
                    if (onNavigate != null) {
                      onNavigate!(1);
                    }
                  },
                ),
                DashboardModuleCard(
                  icon: Icons.alarm_rounded,
                  title: 'Follow-ups',
                  subtitle: 'Cadence reminders',
                  accentColor: const Color(0xFF38BDF8),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FollowupsPage(currentUserId: userId),
                    ),
                  ),
                ),
                DashboardModuleCard(
                  icon: Icons.chat_bubble_rounded,
                  title: 'Messaging',
                  subtitle: 'Direct conversations',
                  accentColor: const Color(0xFF10B981),
                  onTap: () {
                    if (onNavigate != null) {
                      onNavigate!(2);
                    }
                  },
                ),
                DashboardModuleCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'AI Insights',
                  subtitle: 'Connection health & tips',
                  accentColor: const Color(0xFF8B5CF6),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InsightsPage(currentUserId: userId),
                    ),
                  ),
                ),
                DashboardModuleCard(
                  icon: Icons.bubble_chart_rounded,
                  title: 'Circles & Groups',
                  subtitle: 'Shared circles & roles',
                  accentColor: const Color(0xFFF59E0B),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupsPage(
                        currentUserId: userId,
                        currentUserName: effectiveName,
                      ),
                    ),
                  ),
                ),
                DashboardModuleCard(
                  icon: Icons.flag_rounded,
                  title: 'Goals & Habits',
                  subtitle: 'Milestones & initiatives',
                  accentColor: const Color(0xFF06B6D4),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GoalsPage(
                        currentUserId: userId,
                        currentUserName: effectiveName,
                      ),
                    ),
                  ),
                ),
                DashboardModuleCard(
                  icon: Icons.vpn_key_rounded,
                  title: 'Invitations',
                  subtitle: 'Private codes & links',
                  accentColor: const Color(0xFF6366F1),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InvitationsPage(
                        currentUserId: userId,
                        currentUserName: effectiveName,
                      ),
                    ),
                  ),
                ),
                DashboardModuleCard(
                  icon: Icons.shield_rounded,
                  title: 'Privacy Center',
                  subtitle: 'Export data & consent',
                  accentColor: const Color(0xFFA855F7),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrivacyPage(currentUserId: userId),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
