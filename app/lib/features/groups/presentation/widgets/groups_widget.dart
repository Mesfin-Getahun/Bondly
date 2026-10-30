import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/groups_entity.dart';
import '../controllers/groups_controller.dart';

/// Feature: Groups - Card Widget
class GroupCard extends StatelessWidget {
  final GroupEntity group;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onManageMembers;
  final VoidCallback onLeaveOrDelete;

  const GroupCard({
    super.key,
    required this.group,
    required this.currentUserId,
    required this.onTap,
    required this.onEdit,
    required this.onManageMembers,
    required this.onLeaveOrDelete,
  });

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'family':
        return Colors.orange;
      case 'work':
        return Colors.indigo;
      case 'hobbies':
        return Colors.teal;
      case 'community':
        return Colors.purple;
      case 'friends':
      default:
        return AppColors.primary;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'family':
        return Icons.family_restroom_rounded;
      case 'work':
        return Icons.business_center_rounded;
      case 'hobbies':
        return Icons.sports_tennis_rounded;
      case 'community':
        return Icons.diversity_3_rounded;
      case 'friends':
      default:
        return Icons.group_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(group.category);
    final isOwner = group.isOwner(currentUserId);
    final role = group.getRole(currentUserId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon + Name + Pop-up Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: catColor.withAlpha(25),
                    child: Icon(_categoryIcon(group.category), color: catColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: catColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                group.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: catColor,
                                ),
                              ),
                            ),
                            if (group.isPrivate) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock_outline_rounded, size: 10, color: Colors.grey),
                                    SizedBox(width: 2),
                                    Text('Private', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                    onSelected: (val) {
                      switch (val) {
                        case 'members':
                          onManageMembers();
                          break;
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                        case 'leave':
                          onLeaveOrDelete();
                          break;
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'members',
                        child: Row(
                          children: [
                            Icon(Icons.people_outline_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Members & Roles'),
                          ],
                        ),
                      ),
                      if (group.isAdmin(currentUserId))
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Edit Circle'),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: isOwner ? 'delete' : 'leave',
                        child: Row(
                          children: [
                            Icon(
                              isOwner ? Icons.delete_outline_rounded : Icons.exit_to_app_rounded,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isOwner ? 'Delete Circle' : 'Leave Circle',
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (group.description?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Text(
                  group.description!,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Bottom Info: Members Count + User Role
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.group_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        '${group.members.length} ${group.members.length == 1 ? 'member' : 'members'}',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (role != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isOwner
                            ? Colors.amber.shade50
                            : (role == GroupRole.admin ? Colors.blue.shade50 : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isOwner
                              ? Colors.amber.shade300
                              : (role == GroupRole.admin ? Colors.blue.shade200 : Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        role.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isOwner
                              ? Colors.amber.shade900
                              : (role == GroupRole.admin ? Colors.blue.shade800 : Colors.grey.shade700),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feature: Groups - Create or Edit Sheet
class CreateEditGroupSheet extends StatefulWidget {
  final GroupsController controller;
  final String currentUserId;
  final String currentUserName;
  final GroupEntity? existing;

  const CreateEditGroupSheet({
    super.key,
    required this.controller,
    required this.currentUserId,
    required this.currentUserName,
    this.existing,
  });

  @override
  State<CreateEditGroupSheet> createState() => _CreateEditGroupSheetState();
}

class _CreateEditGroupSheetState extends State<CreateEditGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late String _category;
  late bool _isPrivate;

  final _categories = ['Friends', 'Family', 'Work', 'Hobbies', 'Community', 'Other'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _descController = TextEditingController(text: e?.description ?? '');
    _category = e?.category ?? 'Friends';
    _isPrivate = e?.isPrivate ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final nav = Navigator.of(context);

    if (widget.existing != null) {
      final updated = widget.existing!.copyWith(
        name: _nameController.text.trim(),
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        category: _category,
        isPrivate: _isPrivate,
      );
      await widget.controller.editGroup(updated);
    } else {
      await widget.controller.createNewGroup(
        name: _nameController.text.trim(),
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        creatorId: widget.currentUserId,
        creatorName: widget.currentUserName,
        category: _category,
        isPrivate: _isPrivate,
      );
    }

    if (mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Circle' : 'Create New Circle',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Circle Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Circle Name *',
                  hintText: 'e.g. Hiking Enthusiasts, Family Core...',
                  prefixIcon: Icon(Icons.group_work_rounded),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a circle name' : null,
              ),
              const SizedBox(height: 14),

              // Category selector
              const Text('Circle Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _categories.map((c) {
                  final isSelected = _category == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _category = c);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description / Purpose (Optional)',
                  hintText: 'Plan weekend trips and share memories together.',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 12),

              // Private switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Private Circle', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Only Admins can invite new members', style: TextStyle(fontSize: 12)),
                value: _isPrivate,
                onChanged: (v) => setState(() => _isPrivate = v),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Create Circle',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feature: Groups - Member Management Sheet
class GroupMembersSheet extends StatefulWidget {
  final GroupsController controller;
  final GroupEntity group;
  final String currentUserId;

  const GroupMembersSheet({
    super.key,
    required this.controller,
    required this.group,
    required this.currentUserId,
  });

  @override
  State<GroupMembersSheet> createState() => _GroupMembersSheetState();
}

class _GroupMembersSheetState extends State<GroupMembersSheet> {
  void _showAddMemberDialog() {
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Member to Circle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Member Name *',
                hintText: 'Sarah Jenkins',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(
                labelText: 'User ID or Email',
                hintText: 'e.g. user_123 or sarah@example.com',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final uid = idCtrl.text.trim().isNotEmpty
                  ? idCtrl.text.trim()
                  : 'user_${DateTime.now().millisecondsSinceEpoch}';
              final newMember = GroupMemberEntity(
                userId: uid,
                displayName: nameCtrl.text.trim(),
                role: GroupRole.member,
                joinedAt: DateTime.now(),
              );
              await widget.controller.addMemberToGroup(
                groupId: widget.group.id,
                member: newMember,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.group.isOwner(widget.currentUserId);
    final isAdmin = widget.group.isAdmin(widget.currentUserId);
    final canManage = isOwner || isAdmin;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.group.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.group.members.length} Members',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (canManage) ...[
            OutlinedButton.icon(
              onPressed: _showAddMemberDialog,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Add Member to Circle'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
          ],

          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.group.members.length,
              itemBuilder: (ctx, i) {
                final m = widget.group.members[i];
                final isMe = m.userId == widget.currentUserId;
                final isMemberOwner = m.role == GroupRole.owner;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withAlpha(30),
                    child: Text(
                      m.displayName.isNotEmpty ? m.displayName[0].toUpperCase() : 'M',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        m.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('You', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    'Joined ${AppDateUtils.timeAgo(m.joinedAt)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isMemberOwner
                              ? Colors.amber.shade50
                              : (m.role == GroupRole.admin ? Colors.blue.shade50 : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          m.role.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isMemberOwner
                                ? Colors.amber.shade900
                                : (m.role == GroupRole.admin ? Colors.blue.shade800 : Colors.grey.shade700),
                          ),
                        ),
                      ),
                      if (isOwner && !isMemberOwner) ...[
                        const SizedBox(width: 4),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18),
                          onSelected: (val) {
                            if (val == 'promote') {
                              widget.controller.changeMemberRole(
                                groupId: widget.group.id,
                                userId: m.userId,
                                newRole: GroupRole.admin,
                              );
                            } else if (val == 'demote') {
                              widget.controller.changeMemberRole(
                                groupId: widget.group.id,
                                userId: m.userId,
                                newRole: GroupRole.member,
                              );
                            } else if (val == 'remove') {
                              widget.controller.removeMemberFromGroup(
                                groupId: widget.group.id,
                                userId: m.userId,
                              );
                            }
                          },
                          itemBuilder: (ctx) => [
                            if (m.role == GroupRole.member)
                              const PopupMenuItem(value: 'promote', child: Text('Make Admin'))
                            else if (m.role == GroupRole.admin)
                              const PopupMenuItem(value: 'demote', child: Text('Remove Admin')),
                            const PopupMenuItem(
                              value: 'remove',
                              child: Text('Remove from Circle', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
