import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/followups_entity.dart';
import '../controllers/followups_controller.dart';

/// Item tile for a follow-up reminder
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
        return Colors.green;
      case FollowupPriority.medium:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = followup.isOverdue;
    final isDueToday = followup.isDueToday;
    final priorityColor = _priorityColor(followup.priority);

    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOverdue
                ? AppColors.error.withAlpha(90)
                : (isDueToday ? Colors.orange.shade300 : Colors.grey.shade200),
            width: isOverdue || isDueToday ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isOverdue ? AppColors.error.withAlpha(8) : Colors.black.withAlpha(5),
              blurRadius: 6,
              offset: const Offset(0, 2),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
                      // Priority dot
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
                            decoration: followup.isCompleted ? TextDecoration.lineThrough : null,
                            color: followup.isCompleted ? Colors.grey : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Contact name & Cadence
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        followup.contactName,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      if (followup.repeatCadence != 'none') ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.repeat_rounded, size: 14, color: AppColors.primary),
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

                  // Due Date Status
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? AppColors.error.withAlpha(15)
                          : (isDueToday
                              ? Colors.orange.shade50
                              : (followup.isCompleted ? Colors.grey.shade100 : Colors.blue.shade50)),
                      borderRadius: BorderRadius.circular(6),
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
                                ? Colors.deepOrange
                                : (followup.isCompleted ? Colors.grey : Colors.blue.shade800)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Delete action
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet to create or edit a follow-up reminder
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
                    isEditing ? 'Edit Follow-up' : 'New Follow-up Reminder',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Reminder Title *',
                  hintText: 'Catch up over coffee, check on project...',
                  prefixIcon: Icon(Icons.alarm_rounded),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),

              // Contact Name
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Person *',
                  hintText: 'Sarah Jenkins',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a contact name' : null,
              ),
              const SizedBox(height: 12),

              // Due Date Picker Button
              InkWell(
                onTap: _pickDueDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Due Date: ${AppDateUtils.formatShortDate(_dueDate)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Priority Selector
              Row(
                children: [
                  const Text('Priority: ', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 10),
                  ...FollowupPriority.values.map((p) {
                    final isSelected = _priority == p;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: isSelected,
                        label: Text(p.name.toUpperCase()),
                        selectedColor: AppColors.primary,
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
              const SizedBox(height: 12),

              // Repeat Cadence
              DropdownButtonFormField<String>(
                initialValue: _repeatCadence,
                decoration: const InputDecoration(
                  labelText: 'Repeat Cadence',
                  prefixIcon: Icon(Icons.repeat_rounded),
                ),
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
                decoration: const InputDecoration(
                  labelText: 'Private Notes (Optional)',
                  hintText: 'Talk about vacation plans, ask about family...',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
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
