import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/relationships_entity.dart';
import '../controllers/relationships_controller.dart';

/// Feature: Relationships - Widgets adhering strictly to AGENTS.md

/// AGENTS.md Rules 1 & 3: Relationship contact card with 20px radius, 1px border,
/// dark surface (#121824), and overflow-safe layout.
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
        return const Color(0xFFFF6B50); // Coral
      case 'family':
        return const Color(0xFFA855F7); // Purple
      case 'colleague':
        return const Color(0xFF38BDF8); // Sky blue
      case 'mentor':
        return const Color(0xFF10B981); // Emerald
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOverdue ? AppColors.error.withValues(alpha: 0.6) : AppColors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with 12% soft tint container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: typeColor.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: typeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & Category
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
                                  letterSpacing: -0.2,
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
                                  fontSize: 12.5,
                                  color: AppColors.microLabel,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
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
                            Expanded(
                              child: Text(
                                relationship.lastContactDate != null
                                    ? 'Last: ${AppDateUtils.timeAgo(relationship.lastContactDate!)}'
                                    : 'No interactions yet',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Quick Log Interaction Button
                  IconButton(
                    tooltip: 'Log Interaction',
                    icon: const Icon(Icons.add_comment_rounded, color: AppColors.primary, size: 20),
                    onPressed: onLogInteraction,
                  ),
                ],
              ),

              // Cadence status row
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isOverdue ? AppColors.error.withValues(alpha: 0.1) : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOverdue ? AppColors.error.withValues(alpha: 0.3) : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOverdue ? Icons.warning_amber_rounded : Icons.schedule_rounded,
                      size: 15,
                      color: isOverdue ? AppColors.error : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isOverdue
                            ? 'Follow-up overdue (${AppDateUtils.cadenceLabel(relationship.cadenceDays)})'
                            : 'Next reminder: ${relationship.nextFollowUpDate != null ? AppDateUtils.formatShortDate(relationship.nextFollowUpDate!) : "Not set"} (${AppDateUtils.cadenceLabel(relationship.cadenceDays)})',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                          color: isOverdue ? AppColors.error : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog / Sheet to add or edit a contact in Dark Modern Theme
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

  InputDecoration _inputDecoration(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      hintStyle: const TextStyle(color: AppColors.microLabel, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: AppColors.surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Name
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration('Full Name *', Icons.person_outline_rounded),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 12),

              // Nickname
              TextFormField(
                controller: _nicknameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration('Nickname / Alias (Optional)', Icons.tag_rounded),
              ),
              const SizedBox(height: 12),

              // Relationship Type Dropdown
              DropdownButtonFormField<String>(
                initialValue: _relationshipType,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration('Relationship Category', Icons.group_outlined),
                items: _typeOptions
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _relationshipType = v);
                },
              ),
              const SizedBox(height: 12),

              // Follow-up Cadence
              DropdownButtonFormField<int>(
                initialValue: _cadenceDays,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration('Reminder Cadence', Icons.alarm_rounded),
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
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration('Phone', Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('Email', Icons.email_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Summary / Context
              TextFormField(
                controller: _summaryController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration(
                  'Personal Summary / Context',
                  Icons.description_outlined,
                  hint: 'Met at tech meetup, loves hiking...',
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

/// Sheet to log an interaction in Dark Modern Theme
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
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
              Expanded(
                child: Text(
                  'Log Interaction with ${widget.relationship.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Type chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _types.map((t) {
              final isSelected = _selectedType == t['type'];
              return ChoiceChip(
                selected: isSelected,
                avatar: Icon(
                  t['icon'] as IconData,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                label: Text(t['label'] as String),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceElevated,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
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
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'What did you talk about?',
              hintText: 'Discussed project roadmap, caught up on family...',
              labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              hintStyle: const TextStyle(color: AppColors.microLabel, fontSize: 13),
              filled: true,
              fillColor: AppColors.surfaceElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Save Interaction', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
