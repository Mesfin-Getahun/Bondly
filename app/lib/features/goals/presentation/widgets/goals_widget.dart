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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: goal.isOverdue
              ? AppColors.error.withAlpha(90)
              : (goal.isDueSoon ? Colors.orangeAccent : AppColors.border),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                          color: isDone ? AppColors.textTertiary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: catColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: catColor.withAlpha(80), width: 1),
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
                                color: AppColors.privacyAccent.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.privacyAccent.withAlpha(80), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.people_alt_outlined, size: 12, color: AppColors.privacyAccent),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Shared (${goal.participantIds.length})',
                                    style: const TextStyle(fontSize: 10, color: AppColors.privacyAccent, fontWeight: FontWeight.w600),
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
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.textTertiary),
                  color: AppColors.surfaceElevated,
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Goal', style: TextStyle(color: AppColors.textPrimary))),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Goal', style: TextStyle(color: AppColors.error)),
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
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
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
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDone ? Colors.greenAccent : catColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
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
                            : (goal.isDueSoon ? Colors.orangeAccent : AppColors.textSecondary),
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
                              : (goal.isDueSoon ? Colors.orangeAccent : AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ] else
                  const Text('No deadline', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),

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

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    isEditing ? 'Edit Goal' : 'New Relationship Goal',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Goal Title *',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'Call Mom weekly, Coffee with 3 friends...',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  prefixIcon: const Icon(Icons.flag_rounded, color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a goal title' : null,
              ),
              const SizedBox(height: 12),

              // Category Choice Chips
              const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _categories.map((c) {
                  final isSelected = _category == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceElevated,
                    side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border, width: 1),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
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
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Target Count *',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        hintText: '4',
                        hintStyle: const TextStyle(color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        prefixIcon: const Icon(Icons.numbers_rounded, color: AppColors.textSecondary),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
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
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Unit / Metric *',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        hintText: 'calls, times, walks',
                        hintStyle: const TextStyle(color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        prefixIcon: const Icon(Icons.straighten_rounded, color: AppColors.textSecondary),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
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
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1),
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
                            color: _deadline != null ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (_deadline != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                          onPressed: () => setState(() => _deadline = null),
                        )
                      else
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Shared Goal Toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: const Text('Shared Goal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                subtitle: const Text('Visible to circle or partners', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                value: _isShared,
                onChanged: (v) => setState(() => _isShared = v),
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Motivation / Notes (Optional)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'Stay consistent with meaningful connections.',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  prefixIcon: const Icon(Icons.notes_rounded, color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
