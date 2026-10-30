import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/users_controller.dart';
import '../widgets/users_widget.dart';

/// Feature: Users - Profile & Account Settings Page
class UsersPage extends StatefulWidget {
  final AuthController? authController;
  final UsersController? usersController;

  const UsersPage({
    super.key,
    this.authController,
    this.usersController,
  });

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late final UsersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.usersController ?? UsersController();
    _initProfile();
  }

  void _initProfile() {
    final user = widget.authController?.currentUser;
    if (user != null) {
      _controller.init(
        user.id,
        defaultEmail: user.email,
        defaultName: user.displayName,
      );
    }
  }

  @override
  void dispose() {
    if (widget.usersController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _openEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditProfileSheet(controller: _controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authController?.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile & Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _openEditProfileSheet,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final profile = _controller.profile;
          final displayName = profile?.displayName ??
              (user?.displayName?.isNotEmpty == true
                  ? user!.displayName!
                  : (user?.isAnonymous == true ? 'Guest User' : 'Bondly Friend'));
          final email = profile?.email.isNotEmpty == true
              ? profile!.email
              : (user?.email ?? (user?.isAnonymous == true ? 'Guest Session' : ''));
          final bio = profile?.bio;
          final cadenceDays = profile?.defaultCadenceDays ?? 14;
          final pushNotifications = profile?.pushNotifications ?? true;
          final isPrivate = profile?.isPrivate ?? false;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: AppColors.primary.withAlpha(30),
                          child: Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'B',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              if (email.isNotEmpty)
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              if (user?.isAnonymous == true) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.orange.shade200),
                                  ),
                                  child: const Text(
                                    'Anonymous Session',
                                    style: TextStyle(fontSize: 11, color: Colors.deepOrange),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (bio != null && bio.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        bio,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Relationship Cadence Preference
              const Text(
                'Follow-up Cadence',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm_rounded, color: AppColors.primary),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Default Cadence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Suggested catch-up interval for new friends', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    DropdownButton<int>(
                      value: cadenceDays,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 7, child: Text('7 Days')),
                        DropdownMenuItem(value: 14, child: Text('14 Days')),
                        DropdownMenuItem(value: 30, child: Text('30 Days')),
                        DropdownMenuItem(value: 60, child: Text('60 Days')),
                        DropdownMenuItem(value: 90, child: Text('90 Days')),
                      ],
                      onChanged: (v) {
                        if (v != null) _controller.updateDefaultCadence(v);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Account & Social Navigation
              const Text(
                'Account & Social',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),

              _SettingsTile(
                icon: Icons.people_outline_rounded,
                title: 'Connections & Friends',
                subtitle: 'Manage friend requests and mutual connections',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/connections',
                    arguments: {
                      'currentUserId': user?.id,
                      'currentUserName': displayName,
                    },
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.diversity_3_outlined,
                title: 'Circles & Groups',
                subtitle: 'Organize friend circles, group members, and roles',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/groups',
                    arguments: {
                      'currentUserId': user?.id,
                      'currentUserName': displayName,
                    },
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.flag_outlined,
                title: 'Relationship Goals',
                subtitle: 'Personal and shared relationship milestones',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/goals',
                    arguments: {
                      'currentUserId': user?.id,
                      'currentUserName': displayName,
                    },
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.rocket_launch_outlined,
                title: 'Projects & Initiatives',
                subtitle: 'Collaborative projects, shared tasks, and milestones',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/projects',
                    arguments: {
                      'currentUserId': user?.id,
                      'currentUserName': displayName,
                    },
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.qr_code_2_rounded,
                title: 'Invitation Links & Codes',
                subtitle: 'Share private invite links and redeem codes',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/invitations',
                    arguments: {
                      'currentUserId': user?.id,
                      'currentUserName': displayName,
                    },
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notification Center',
                subtitle: 'View in-app alerts and activity notifications',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/notifications',
                    arguments: {
                      'currentUserId': user?.id,
                    },
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.shield_outlined,
                title: 'Privacy & Data Export',
                subtitle: 'Manage consent, export private records, or delete account',
                onTap: () {
                  Navigator.pushNamed(context, '/privacy');
                },
              ),
              _SettingsTile(
                icon: Icons.report_problem_outlined,
                title: 'Safety & Moderation Reports',
                subtitle: 'Submit confidential reports and track status',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/reports',
                    arguments: {
                      'currentUserId': user?.id,
                      'currentUserName': displayName,
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              // Preferences Section
              const Text(
                'Preferences & Privacy',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                      title: const Text('Push Reminders', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Daily follow-up reminders and connection requests', style: TextStyle(fontSize: 12)),
                      value: pushNotifications,
                      onChanged: (val) => _controller.togglePushNotifications(val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.visibility_off_outlined, color: AppColors.primary),
                      title: const Text('Private Profile', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Hide profile from public friend search', style: TextStyle(fontSize: 12)),
                      value: isPrivate,
                      onChanged: (val) => _controller.toggleIsPrivate(val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Sign Out Button
              if (widget.authController != null)
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => widget.authController!.signOut(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign Out of Bondly'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
