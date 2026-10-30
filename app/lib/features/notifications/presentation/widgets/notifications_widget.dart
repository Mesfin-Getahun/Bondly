import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/notifications_entity.dart';

/// Feature: Notifications - Tile Widget
class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.primary.withAlpha(12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread ? AppColors.primary.withAlpha(40) : Colors.grey.shade200,
          ),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: notification.color.withAlpha(25),
                child: Icon(notification.icon, color: notification.color, size: 20),
              ),
              if (isUnread)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                notification.body,
                style: TextStyle(
                  fontSize: 12.5,
                  color: isUnread ? Colors.black87 : Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                AppDateUtils.timeAgo(notification.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.grey),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
