import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/followups_entity.dart';
import '../controllers/followups_controller.dart';

/// Feature: Followups - Widgets adhering strictly to AGENTS.md

/// AGENTS.md Rules 1 & 3: Followup reminder tile with 20px radius, 1px border,
/// dark surface (#121824), and overflow-safe typography.
class FollowupTile extends StatelessWidget {
  final FollowupEntity followup;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const FollowupTile({
    super.key,
    required this.followup,
    required this.onToggle,
    required this.onDelete,
    this.onEdit,
  });

  Color _priorityColor(FollowupPriority p) {
    switch (p) {
      case FollowupPriority.high:
        return AppColors.error;
      case FollowupPriority.low:
        return const Color(0xFF10B981); // Emerald
      case FollowupPriority.medium:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = followup.isOverdue;
    final isDueToday = followup.isDueToday;
    final priorityColor = _priorityColor(followup.priority);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOverdue
                  ? AppColors.error.withValues(alpha: 0.6)
                  : (isDueToday ? const Color(0xFFF59E0B).withValues(alpha: 0.6) : AppColors.border),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Checkbox(
                  value: followup.isCompleted,
                  activeColor: AppColors.primary,
                  checkColor: Colors.white,
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  onChanged: onToggle,
                ),
              ),
              const SizedBox(width: 8),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Priority indicator dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: priorityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            followup.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: followup.isCompleted ? AppColors.microLabel : AppColors.textPrimary,
                              decoration: followup.isCompleted ? TextDecoration.lineThrough : null,
                              decorationColor: AppColors.microLabel,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Contact name & Cadence
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            followup.contactName,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (followup.repeatCadence != 'none') ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.repeat_rounded, size: 13, color: AppColors.primary),
                          const SizedBox(width: 3),
                          Text(
                            followup.repeatCadence,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Due Date Status Badge
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? AppColors.error.withValues(alpha: 0.12)
                            : (isDueToday
                                ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                                : AppColors.surfaceElevated),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isOverdue
                              ? AppColors.error.withValues(alpha: 0.3)
                              : (isDueToday
                                  ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                                  : AppColors.border),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        followup.isCompleted
                            ? 'Completed'
                            : (isOverdue
                                ? 'Overdue (${AppDateUtils.formatShortDate(followup.dueDate)})'
                                : (isDueToday
                                    ? 'Due Today'
                                    : 'Due: ${AppDateUtils.formatShortDate(followup.dueDate)}')),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isOverdue
                              ? AppColors.error
                              : (isDueToday
                                  ? const Color(0xFFF59E0B)
                                  : (followup.isCompleted ? AppColors.microLabel : AppColors.textSecondary)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Delete action
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.microLabel),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sheet to create or edit a follow-up reminder in Dark Modern Theme
class AddEditFollowupSheet extends StatefulWidget {
  final FollowupsController controller;
  final FollowupEntity? existing;
  final String? defaultContactName;
  final String? defaultRelationshipId;

  const AddEditFollowupSheet({
    super.key,
    required this.controller,
    this.existing,
    this.defaultContactName,
    this.defaultRelationshipId,
  });

  @override
  State<AddEditFollowupSheet> createState() => _AddEditFollowupSheetState();
}

class _AddEditFollowupSheetState extends State<AddEditFollowupSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contactController;
  late final TextEditingController _notesController;

  late DateTime _dueDate;
  late FollowupPriority _priority;
  late String _repeatCadence;

  final _cadenceOptions = [
    {'value': 'none', 'label': 'Does not repeat'},
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'biweekly', 'label': 'Every 2 weeks'},
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'quarterly', 'label': 'Quarterly'},
    {'value': 'yearly', 'label': 'Yearly'},
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _contactController =
        TextEditingController(text: e?.contactName ?? (widget.defaultContactName ?? ''));
    _notesController = TextEditingController(text: e?.notes ?? '');

    _dueDate = e?.dueDate ?? DateTime.now().add(const Duration(days: 3));
    _priority = e?.priority ?? FollowupPriority.medium;
    _repeatCadence = e?.repeatCadence ?? 'none';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.existing != null) {
      final updated = widget.existing!.copyWith(
        title: _titleController.text.trim(),
        contactName: _contactController.text.trim(),
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        dueDate: _dueDate,
        priority: _priority,
        repeatCadence: _repeatCadence,
      );
      await widget.controller.updateFollowup(updated);
    } else {
      await widget.controller.createFollowup(
        contactName: _contactController.text.trim(),
        title: _titleController.text.trim(),
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        dueDate: _dueDate,
        priority: _priority,
        repeatCadence: _repeatCadence,
        relationshipId: widget.defaultRelationshipId,
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
                    isEditing ? 'Edit Follow-up' : 'New Follow-up Reminder',
                    style: const TextStyle(
                      fontSize: 18,
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

              // Title
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration(
                  'Reminder Title *',
                  Icons.alarm_rounded,
                  hint: 'Catch up over coffee, check on project...',
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),

              // Contact Name
              TextFormField(
                controller: _contactController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration('Contact Person *', Icons.person_outline_rounded, hint: 'Sarah Jenkins'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a contact name' : null,
              ),
              const SizedBox(height: 12),

              // Due Date Picker Button
              InkWell(
                onTap: _pickDueDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Due Date: ${AppDateUtils.formatShortDate(_dueDate)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.microLabel),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Priority Selector
              Row(
                children: [
                  const Text('Priority: ', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(width: 10),
                  ...FollowupPriority.values.map((p) {
                    final isSelected = _priority == p;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: isSelected,
                        label: Text(p.name.toUpperCase()),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceElevated,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 1,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _priority = p);
                        },
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 14),

              // Repeat Cadence
              DropdownButtonFormField<String>(
                initialValue: _repeatCadence,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration('Repeat Cadence', Icons.repeat_rounded),
                items: _cadenceOptions
                    .map((c) => DropdownMenuItem(value: c['value'], child: Text(c['label']!)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _repeatCadence = v);
                },
              ),
              const SizedBox(height: 12),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration(
                  'Private Notes (Optional)',
                  Icons.notes_rounded,
                  hint: 'Talk about plans, ask about family...',
                ),
              ),
              const SizedBox(height: 24),

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
                  isEditing ? 'Save Changes' : 'Schedule Follow-up',
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
