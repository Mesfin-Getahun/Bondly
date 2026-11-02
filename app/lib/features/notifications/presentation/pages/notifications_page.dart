import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notifications_widget.dart';

/// Feature: Notifications - Main Page
///
/// In-app and push notification alerts for relationship cadences,
/// messages, friend requests, and collaborative milestones.
class NotificationsPage extends StatefulWidget {
  final String? currentUserId;
  final NotificationsController? controller;

  const NotificationsPage({
    super.key,
    this.currentUserId,
    this.controller,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? NotificationsController();
    if (widget.currentUserId != null) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void didUpdateWidget(covariant NotificationsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUserId != null && widget.currentUserId != oldWidget.currentUserId) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _controller.markAllRead(),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: const Text('Mark all read', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = _controller.filteredNotifications;

          return Column(
            children: [
              // Filter Chips Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text('All (${_controller.totalCount})'),
                      selected: _controller.filter == 'All',
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceElevated,
                      side: BorderSide(
                        color: _controller.filter == 'All' ? AppColors.primary : AppColors.border,
                        width: 1,
                      ),
                      labelStyle: TextStyle(
                        color: _controller.filter == 'All' ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        if (val) _controller.setFilter('All');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('Unread (${_controller.unreadCount})'),
                      selected: _controller.filter == 'Unread',
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceElevated,
                      side: BorderSide(
                        color: _controller.filter == 'Unread' ? AppColors.primary : AppColors.border,
                        width: 1,
                      ),
                      labelStyle: TextStyle(
                        color: _controller.filter == 'Unread' ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        if (val) _controller.setFilter('Unread');
                      },
                    ),
                  ],
                ),
              ),

              // Notification List
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.notifications_off_outlined, size: 60, color: AppColors.microLabel),
                              const SizedBox(height: 16),
                              Text(
                                _controller.filter == 'Unread'
                                    ? 'No unread notifications.\nYou\'re all caught up!'
                                    : 'No notifications yet.\nYou will receive updates when friends connect or send messages.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: notifications.length,
                        itemBuilder: (ctx, i) {
                          final n = notifications[i];
                          return NotificationTile(
                            notification: n,
                            onTap: () {
                              if (!n.isRead) _controller.markRead(n.id);
                              // Handle navigation if route provided
                              final route = n.data['route'] as String?;
                              if (route != null && mounted) {
                                Navigator.pushNamed(context, route, arguments: n.data);
                              }
                            },
                            onDelete: () => _controller.delete(n.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
