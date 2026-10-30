import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/relationships_entity.dart';
import '../controllers/relationships_controller.dart';

/// Relationship contact card widget
class RelationshipCard extends StatelessWidget {
  final RelationshipEntity relationship;
  final VoidCallback onTap;
  final VoidCallback onLogInteraction;

  const RelationshipCard({
    super.key,
    required this.relationship,
    required this.onTap,
    required this.onLogInteraction,
  });

  Color _badgeColor(String type) {
    switch (type.toLowerCase()) {
      case 'bestie':
        return const Color(0xFFE91E63);
      case 'family':
        return const Color(0xFF9C27B0);
      case 'colleague':
        return const Color(0xFF3F51B5);
      case 'mentor':
        return const Color(0xFF009688);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = relationship.name.isNotEmpty
        ? relationship.name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase()
        : '?';

    final isOverdue = relationship.isFollowUpDue;
    final typeColor = _badgeColor(relationship.relationshipType);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOverdue ? AppColors.error.withAlpha(90) : Colors.grey.shade200,
            width: isOverdue ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isOverdue ? AppColors.error.withAlpha(12) : Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 26,
                  backgroundColor: typeColor.withAlpha(25),
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: typeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name & Type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              relationship.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (relationship.nickname != null && relationship.nickname!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '(${relationship.nickname})',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              relationship.relationshipType,
                              style: TextStyle(
                                color: typeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (relationship.lastContactDate != null)
                            Text(
                              'Last: ${AppDateUtils.timeAgo(relationship.lastContactDate!)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            )
                          else
                            const Text(
                              'No interactions yet',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Quick Log Interaction Button
                IconButton(
                  tooltip: 'Log Interaction',
                  icon: const Icon(Icons.add_comment_outlined, color: AppColors.primary),
                  onPressed: onLogInteraction,
                ),
              ],
            ),

            // Reminder status row
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isOverdue ? AppColors.error.withAlpha(15) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isOverdue ? Icons.warning_amber_rounded : Icons.schedule_rounded,
                    size: 15,
                    color: isOverdue ? AppColors.error : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOverdue
                        ? 'Follow-up overdue (${AppDateUtils.cadenceLabel(relationship.cadenceDays)})'
                        : 'Next reminder: ${relationship.nextFollowUpDate != null ? AppDateUtils.formatShortDate(relationship.nextFollowUpDate!) : "Not set"} (${AppDateUtils.cadenceLabel(relationship.cadenceDays)})',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                      color: isOverdue ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog / Sheet to add or edit a contact
class AddEditRelationshipSheet extends StatefulWidget {
  final RelationshipsController controller;
  final RelationshipEntity? existing;

  const AddEditRelationshipSheet({super.key, required this.controller, this.existing});

  @override
  State<AddEditRelationshipSheet> createState() => _AddEditRelationshipSheetState();
}

class _AddEditRelationshipSheetState extends State<AddEditRelationshipSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _summaryController;

  late String _relationshipType;
  late int _cadenceDays;
  late int _importance;

  final _typeOptions = ['Bestie', 'Friend', 'Family', 'Colleague', 'Mentor', 'Other'];
  final _cadenceOptions = [
    {'days': 7, 'label': 'Weekly (Every 7 days)'},
    {'days': 14, 'label': 'Bi-weekly (Every 14 days)'},
    {'days': 30, 'label': 'Monthly (Every 30 days)'},
    {'days': 90, 'label': 'Quarterly (Every 90 days)'},
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _nicknameController = TextEditingController(text: e?.nickname ?? '');
    _phoneController = TextEditingController(text: e?.phone ?? '');
    _emailController = TextEditingController(text: e?.email ?? '');
    _summaryController = TextEditingController(text: e?.summary ?? '');

    _relationshipType = e?.relationshipType ?? 'Friend';
    _cadenceDays = e?.cadenceDays ?? 14;
    _importance = e?.importance ?? 3;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.existing != null) {
      final updated = widget.existing!.copyWith(
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim().isNotEmpty ? _nicknameController.text.trim() : null,
        relationshipType: _relationshipType,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        summary: _summaryController.text.trim().isNotEmpty ? _summaryController.text.trim() : null,
        cadenceDays: _cadenceDays,
        importance: _importance,
      );
      await widget.controller.updateRelationship(updated);
    } else {
      await widget.controller.createRelationship(
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim().isNotEmpty ? _nicknameController.text.trim() : null,
        relationshipType: _relationshipType,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        summary: _summaryController.text.trim().isNotEmpty ? _summaryController.text.trim() : null,
        cadenceDays: _cadenceDays,
        importance: _importance,
      );
    }

    if (mounted) Navigator.pop(context);
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
                    isEditing ? 'Edit Contact' : 'Add Private Contact',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 12),

              // Nickname
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname / Alias (Optional)',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
              ),
              const SizedBox(height: 12),

              // Relationship Type Dropdown
              DropdownButtonFormField<String>(
                initialValue: _relationshipType,
                decoration: const InputDecoration(
                  labelText: 'Relationship Category',
                  prefixIcon: Icon(Icons.group_outlined),
                ),
                items: _typeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _relationshipType = v);
                },
              ),
              const SizedBox(height: 12),

              // Follow-up Cadence
              DropdownButtonFormField<int>(
                initialValue: _cadenceDays,
                decoration: const InputDecoration(
                  labelText: 'Reminder Cadence',
                  prefixIcon: Icon(Icons.alarm_rounded),
                ),
                items: _cadenceOptions.map((c) {
                  return DropdownMenuItem<int>(
                    value: c['days'] as int,
                    child: Text(c['label'] as String),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _cadenceDays = v);
                },
              ),
              const SizedBox(height: 12),

              // Phone & Email
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Summary / Bio
              TextFormField(
                controller: _summaryController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Personal Summary / Context',
                  hintText: 'Met at tech meetup, loves hiking and design...',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Add Contact',
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

/// Sheet to log an interaction (Call, Coffee, Walk, Message)
class LogInteractionSheet extends StatefulWidget {
  final RelationshipsController controller;
  final RelationshipEntity relationship;

  const LogInteractionSheet({
    super.key,
    required this.controller,
    required this.relationship,
  });

  @override
  State<LogInteractionSheet> createState() => _LogInteractionSheetState();
}

class _LogInteractionSheetState extends State<LogInteractionSheet> {
  final _summaryController = TextEditingController();
  String _selectedType = 'coffee';

  final _types = [
    {'type': 'coffee', 'label': 'Coffee / Meal', 'icon': Icons.coffee_rounded},
    {'type': 'call', 'label': 'Phone Call', 'icon': Icons.phone_rounded},
    {'type': 'message', 'label': 'Text / Chat', 'icon': Icons.chat_rounded},
    {'type': 'meeting', 'label': 'Meeting', 'icon': Icons.handshake_rounded},
    {'type': 'walk', 'label': 'Walk / Activity', 'icon': Icons.directions_walk_rounded},
  ];

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  void _submit() async {
    final summary = _summaryController.text.trim();
    if (summary.isEmpty) return;

    await widget.controller.logInteraction(
      relationshipId: widget.relationship.id,
      type: _selectedType,
      summary: summary,
      date: DateTime.now(),
    );

    if (mounted) Navigator.pop(context);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Log Interaction with ${widget.relationship.name}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Type chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _types.map((t) {
              final isSelected = _selectedType == t['type'];
              return ChoiceChip(
                selected: isSelected,
                avatar: Icon(t['icon'] as IconData, size: 16, color: isSelected ? Colors.white : AppColors.primary),
                label: Text(t['label'] as String),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedType = t['type'] as String);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Summary input
          TextField(
            controller: _summaryController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'What did you talk about?',
              hintText: 'Discussed project roadmap, caught up on family...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
            child: const Text('Save Interaction', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
