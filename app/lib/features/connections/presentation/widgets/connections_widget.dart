import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/connections_entity.dart';
import '../controllers/connections_controller.dart';

/// Card for an accepted mutual friend
class FriendConnectionCard extends StatelessWidget {
  final ConnectionEntity connection;
  final String currentUserId;
  final VoidCallback onMessage;
  final VoidCallback onRemove;
  final VoidCallback onBlock;

  const FriendConnectionCard({
    super.key,
    required this.connection,
    required this.currentUserId,
    required this.onMessage,
    required this.onRemove,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final name = connection.otherUserName(currentUserId);
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withAlpha(25),
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Connected • ${AppDateUtils.timeAgo(connection.updatedAt)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action: Message
          ElevatedButton.icon(
            onPressed: onMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withAlpha(25),
              foregroundColor: AppColors.primaryDark,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            label: const Text('Message', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),

          // More Options Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
            onSelected: (val) {
              if (val == 'remove') onRemove();
              if (val == 'block') onBlock();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove_outlined, size: 18, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Remove Friend', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block_flipped, size: 18, color: Colors.grey),
                    SizedBox(width: 10),
                    Text('Block User'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card for an incoming friend request
class IncomingRequestCard extends StatelessWidget {
  final ConnectionEntity connection;
  final String currentUserId;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingRequestCard({
    super.key,
    required this.connection,
    required this.currentUserId,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final name = connection.userAName;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withAlpha(25),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sent you a connection request • ${AppDateUtils.timeAgo(connection.createdAt)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card for an outgoing pending friend request
class SentRequestCard extends StatelessWidget {
  final ConnectionEntity connection;
  final VoidCallback onCancel;

  const SentRequestCard({
    super.key,
    required this.connection,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final name = connection.userBName;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade100,
            child: Text(
              initials,
              style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pending approval • ${AppDateUtils.timeAgo(connection.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onCancel,
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

/// Sheet to send a new friend request
class SendRequestSheet extends StatefulWidget {
  final ConnectionsController controller;
  final String currentUserName;

  const SendRequestSheet({
    super.key,
    required this.controller,
    required this.currentUserName,
  });

  @override
  State<SendRequestSheet> createState() => _SendRequestSheetState();
}

class _SendRequestSheetState extends State<SendRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final otherId = _userIdController.text.trim();
    final otherName = _nameController.text.trim();

    final success = await widget.controller.sendRequest(
      otherUserId: otherId,
      currentUserName: widget.currentUserName,
      otherUserName: otherName,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request sent!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.controller.errorMessage ?? 'Failed to send request.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Connect with a Friend',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Friend's Name *",
                hintText: 'Sarah Jenkins',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: "Friend's User ID or Email *",
                hintText: 'Enter user UID or account identifier',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a User ID' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Send Friend Request', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
