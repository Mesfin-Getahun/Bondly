import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/projects_entity.dart';
import '../controllers/projects_controller.dart';

/// Feature: Projects - Card Widget
class ProjectCard extends StatelessWidget {
  final ProjectEntity project;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'trip':
        return Colors.teal;
      case 'event':
        return Colors.orange;
      case 'creative':
        return Colors.purple;
      case 'personal':
        return Colors.indigo;
      case 'collaboration':
      default:
        return AppColors.primary;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'planning':
        return Colors.amber.shade800;
      case 'active':
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(project.category);
    final statusColor = _statusColor(project.status);
    final progress = project.taskProgress;

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
              // Header: Category + Status Chip + Menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: catColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          project.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: catColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          project.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                    onSelected: (val) {
                      if (val == 'edit') onEdit();
                      if (val == 'delete') onDelete();
                      if (val == 'details') onTap();
                    },
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(value: 'details', child: Text('Tasks & Milestones')),
                      PopupMenuItem(value: 'edit', child: Text('Edit Project')),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Project', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                project.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              if (project.description?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  project.description!,
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 14),

              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${project.completedTasksCount} of ${project.totalTasksCount} tasks done',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: catColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(catColor),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Footer: Collaborators & Target Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_outline_rounded, size: 15, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${project.participantIds.length} ${project.participantIds.length == 1 ? 'member' : 'members'}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (project.dueDate != null)
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Due ${AppDateUtils.formatShortDate(project.dueDate!)}',
                          style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                      ],
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

/// Feature: Projects - Create or Edit Sheet
class CreateEditProjectSheet extends StatefulWidget {
  final ProjectsController controller;
  final String currentUserId;
  final String currentUserName;
  final ProjectEntity? existing;

  const CreateEditProjectSheet({
    super.key,
    required this.controller,
    required this.currentUserId,
    required this.currentUserName,
    this.existing,
  });

  @override
  State<CreateEditProjectSheet> createState() => _CreateEditProjectSheetState();
}

class _CreateEditProjectSheetState extends State<CreateEditProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late String _category;
  late String _status;
  DateTime? _dueDate;

  final _categories = ['Collaboration', 'Trip', 'Event', 'Creative', 'Personal', 'Other'];
  final _statuses = ['active', 'planning', 'completed'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _descController = TextEditingController(text: e?.description ?? '');
    _category = e?.category ?? 'Collaboration';
    _status = e?.status ?? 'active';
    _dueDate = e?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final nav = Navigator.of(context);

    if (widget.existing != null) {
      final updated = widget.existing!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        category: _category,
        status: _status,
        dueDate: _dueDate,
      );
      await widget.controller.editProject(updated);
    } else {
      await widget.controller.createNewProject(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
        creatorId: widget.currentUserId,
        creatorName: widget.currentUserName,
        category: _category,
        status: _status,
        dueDate: _dueDate,
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
                    isEditing ? 'Edit Project' : 'New Initiative / Project',
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
                  labelText: 'Project Title *',
                  hintText: 'Summer Road Trip, Book Launch, Housewarming...',
                  prefixIcon: Icon(Icons.rocket_launch_rounded),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 14),

              // Category selector
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

              // Status Dropdown
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Project Status',
                  prefixIcon: Icon(Icons.donut_large_rounded),
                ),
                items: _statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _status = v);
                },
              ),
              const SizedBox(height: 12),

              // Due Date Button
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
                          _dueDate != null
                              ? 'Target Date: ${AppDateUtils.formatShortDate(_dueDate!)}'
                              : 'Set Target Due Date (Optional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _dueDate != null ? AppColors.textPrimary : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      if (_dueDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _dueDate = null),
                        )
                      else
                        const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description / Goals (Optional)',
                  hintText: 'Key objectives and notes for collaborators...',
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
                  isEditing ? 'Save Changes' : 'Create Project',
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

/// Feature: Projects - Detail & Tasks/Milestones Sheet
class ProjectDetailSheet extends StatefulWidget {
  final ProjectsController controller;
  final ProjectEntity project;

  const ProjectDetailSheet({
    super.key,
    required this.controller,
    required this.project,
  });

  @override
  State<ProjectDetailSheet> createState() => _ProjectDetailSheetState();
}

class _ProjectDetailSheetState extends State<ProjectDetailSheet> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _taskTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taskTitleController.dispose();
    super.dispose();
  }

  void _addTask() async {
    final title = _taskTitleController.text.trim();
    if (title.isEmpty) return;

    _taskTitleController.clear();
    await widget.controller.addNewTask(
      projectId: widget.project.id,
      title: title,
    );
  }

  void _addMilestoneDialog() {
    final titleCtrl = TextEditingController();
    DateTime pickedDate = DateTime.now().add(const Duration(days: 14));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Milestone'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Milestone Title',
                  hintText: 'Phase 1 Complete, Bookings Finalized...',
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month, color: AppColors.primary),
                title: Text('Target: ${AppDateUtils.formatShortDate(pickedDate)}'),
                trailing: const Icon(Icons.edit_calendar_rounded),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: pickedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (d != null) {
                    setDialogState(() => pickedDate = d);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                await widget.controller.addNewMilestone(
                  projectId: widget.project.id,
                  title: titleCtrl.text.trim(),
                  targetDate: pickedDate,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.project.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.project.completedTasksCount} of ${widget.project.totalTasksCount} tasks completed',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Tasks', icon: Icon(Icons.checklist_rounded)),
              Tab(text: 'Milestones', icon: Icon(Icons.flag_circle_outlined)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tasks Tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Quick add task input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _taskTitleController,
                              decoration: const InputDecoration(
                                hintText: 'Add a new task...',
                                prefixIcon: Icon(Icons.add_task_rounded),
                              ),
                              onSubmitted: (_) => _addTask(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            icon: const Icon(Icons.arrow_upward_rounded),
                            onPressed: _addTask,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Expanded(
                        child: widget.project.tasks.isEmpty
                            ? const Center(
                                child: Text('No tasks yet. Type a task title above to add one!'),
                              )
                            : ListView.builder(
                                itemCount: widget.project.tasks.length,
                                itemBuilder: (ctx, i) {
                                  final t = widget.project.tasks[i];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Checkbox(
                                      value: t.isCompleted,
                                      onChanged: (val) => widget.controller.toggleTask(
                                        widget.project.id,
                                        t.id,
                                        val ?? false,
                                      ),
                                    ),
                                    title: Text(
                                      t.title,
                                      style: TextStyle(
                                        decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                                        color: t.isCompleted ? Colors.grey : AppColors.textPrimary,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                                      onPressed: () => widget.controller.removeTask(
                                        widget.project.id,
                                        t.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                // Milestones Tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _addMilestoneDialog,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Timeline Milestone'),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: widget.project.milestones.isEmpty
                            ? const Center(
                                child: Text('No milestones set yet.'),
                              )
                            : ListView.builder(
                                itemCount: widget.project.milestones.length,
                                itemBuilder: (ctx, i) {
                                  final m = widget.project.milestones[i];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: IconButton(
                                      icon: Icon(
                                        m.isReached
                                            ? Icons.check_circle_rounded
                                            : Icons.radio_button_unchecked_rounded,
                                        color: m.isReached ? Colors.green : Colors.grey,
                                      ),
                                      onPressed: () => widget.controller.toggleMilestone(
                                        widget.project.id,
                                        m.id,
                                        !m.isReached,
                                      ),
                                    ),
                                    title: Text(
                                      m.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        decoration: m.isReached ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Target: ${AppDateUtils.formatShortDate(m.targetDate)}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
