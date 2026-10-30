import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/goals_entity.dart';
import '../controllers/goals_controller.dart';

/// Feature: Goals - Card Widget
class GoalCard extends StatelessWidget {
  final GoalEntity goal;
  final VoidCallback onIncrement;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onIncrement,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'family':
        return Colors.orange;
      case 'career':
        return Colors.indigo;
      case 'health':
        return Colors.green;
      case 'social':
        return Colors.purple;
      case 'connection':
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(goal.category);
    final percent = goal.progressPercent;
    final isDone = goal.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goal.isOverdue
              ? AppColors.error.withAlpha(80)
              : (goal.isDueSoon ? Colors.orange.shade300 : Colors.grey.shade200),
          width: goal.isOverdue || goal.isDueSoon ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Checkbox + Title + Category + Options
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isDone,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (v) => onToggleComplete(v ?? false),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? Colors.grey : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: catColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              goal.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: catColor,
                              ),
                            ),
                          ),
                          if (goal.isShared) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.people_alt_outlined, size: 12, color: Colors.blue.shade700),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Shared (${goal.participantIds.length})',
                                    style: TextStyle(fontSize: 10, color: Colors.blue.shade800, fontWeight: FontWeight.w600),
                                  ),
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
                    if (val == 'edit') onEdit();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit Goal')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Goal', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              ],
            ),

            if (goal.description?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 44),
                child: Text(
                  goal.description!,
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Progress Bar & Counts
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${goal.currentCount} / ${goal.targetCount} ${goal.unit}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        '${(percent * 100).toInt()}%',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: catColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDone ? Colors.green : catColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Footer: Deadline & Quick +1 Increment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (goal.deadline != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: goal.isOverdue
                            ? AppColors.error
                            : (goal.isDueSoon ? Colors.orange : Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        goal.isOverdue
                            ? 'Overdue (${AppDateUtils.formatShortDate(goal.deadline!)})'
                            : (goal.isDueSoon
                                ? 'Due Soon'
                                : 'Target: ${AppDateUtils.formatShortDate(goal.deadline!)}'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: goal.isOverdue
                              ? AppColors.error
                              : (goal.isDueSoon ? Colors.orange.shade800 : Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ] else
                  const Text('No deadline', style: TextStyle(fontSize: 11, color: Colors.grey)),

                // +1 Quick Log Button
                if (!isDone)
                  ElevatedButton.icon(
                    onPressed: onIncrement,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text('+1 ${goal.unit}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: catColor.withAlpha(25),
                      foregroundColor: catColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Feature: Goals - Create or Edit Sheet
class CreateEditGoalSheet extends StatefulWidget {
  final GoalsController controller;
  final String currentUserId;
  final String currentUserName;
  final GoalEntity? existing;

  const CreateEditGoalSheet({
    super.key,
    required this.controller,
    required this.currentUserId,
    required this.currentUserName,
    this.existing,
  });

  @override
  State<CreateEditGoalSheet> createState() => _CreateEditGoalSheetState();
}

class _CreateEditGoalSheetState extends State<CreateEditGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _targetController;
  late final TextEditingController _unitController;

  late String _category;
  late bool _isShared;
  DateTime? _deadline;

  final _categories = ['Connection', 'Family', 'Career', 'Health', 'Social', 'Personal'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _descController = TextEditingController(text: e?.description ?? '');
    _targetController = TextEditingController(text: '${e?.targetCount ?? 4}');
    _unitController = TextEditingController(text: e?.unit ?? 'times');
    _category = e?.category ?? 'Connection';
    _isShared = e?.isShared ?? false;
    _deadline = e?.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final target = int.tryParse(_targetController.text.trim()) ?? 1;
    final nav = Navigator.of(context);

    if (widget.existing != null) {
      final updated = widget.existing!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        targetCount: target,
        unit: _unitController.text.trim().isNotEmpty ? _unitController.text.trim() : 'times',
        category: _category,
        isShared: _isShared,
        deadline: _deadline,
      );
      await widget.controller.editGoal(updated);
    } else {
      await widget.controller.createNewGoal(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        creatorId: widget.currentUserId,
        creatorName: widget.currentUserName,
        isShared: _isShared,
        targetCount: target,
        unit: _unitController.text.trim().isNotEmpty ? _unitController.text.trim() : 'times',
        category: _category,
        deadline: _deadline,
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
                    isEditing ? 'Edit Goal' : 'New Relationship Goal',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title *',
                  hintText: 'Call Mom weekly, Coffee with 3 friends...',
                  prefixIcon: Icon(Icons.flag_rounded),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a goal title' : null,
              ),
              const SizedBox(height: 12),

              // Category Choice Chips
              const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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

              // Target count & Unit
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _targetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Target Count *',
                        hintText: '4',
                        prefixIcon: Icon(Icons.numbers_rounded),
                      ),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Enter a number > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit / Metric *',
                        hintText: 'calls, times, walks',
                        prefixIcon: Icon(Icons.straighten_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Deadline Picker
              InkWell(
                onTap: _pickDeadline,
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
                          _deadline != null
                              ? 'Deadline: ${AppDateUtils.formatShortDate(_deadline!)}'
                              : 'Set a Target Deadline (Optional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _deadline != null ? AppColors.textPrimary : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      if (_deadline != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _deadline = null),
                        )
                      else
                        const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Shared Goal Toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Shared Goal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Visible to circle or partners', style: TextStyle(fontSize: 12)),
                value: _isShared,
                onChanged: (v) => setState(() => _isShared = v),
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Motivation / Notes (Optional)',
                  hintText: 'Stay consistent with meaningful connections.',
                  prefixIcon: Icon(Icons.notes_rounded),
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
                child: Text(
                  isEditing ? 'Save Changes' : 'Create Goal',
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
