import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/projects_entity.dart';
import '../controllers/projects_controller.dart';
import '../widgets/projects_widget.dart';

/// Feature: Projects - Main Page
///
/// Projects, collaborative tasks, and timeline milestones.
class ProjectsPage extends StatefulWidget {
  final String? currentUserId;
  final String? currentUserName;
  final ProjectsController? controller;

  const ProjectsPage({
    super.key,
    this.currentUserId,
    this.currentUserName,
    this.controller,
  });

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late final ProjectsController _controller;
  final _searchController = TextEditingController();

  final _statuses = ['All', 'Active', 'Planning', 'Completed'];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ProjectsController();
    if (widget.currentUserId != null) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void didUpdateWidget(covariant ProjectsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUserId != null && widget.currentUserId != oldWidget.currentUserId) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showCreateEditSheet([ProjectEntity? existing]) {
    final userId = widget.currentUserId ?? '';
    final userName = widget.currentUserName ?? 'Me';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CreateEditProjectSheet(
        controller: _controller,
        currentUserId: userId,
        currentUserName: userName,
        existing: existing,
      ),
    );
  }

  void _showProjectDetails(ProjectEntity project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ProjectDetailSheet(
        controller: _controller,
        project: project,
      ),
    );
  }

  void _confirmDelete(ProjectEntity project) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text('Are you sure you want to delete "${project.title}" and its tasks?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _controller.delete(project.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
        title: const Text('Projects & Initiatives'),
        actions: [
          IconButton(
            tooltip: 'New Project',
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _showCreateEditSheet(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.rocket_launch_rounded),
        label: const Text('New Project', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showCreateEditSheet(),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = _controller.filteredProjects;

          return Column(
            children: [
              // Summary Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MetricItem(label: 'Total Projects', count: _controller.totalProjects),
                    Container(height: 30, width: 1, color: AppColors.border),
                    _MetricItem(label: 'Active', count: _controller.activeProjects),
                    Container(height: 30, width: 1, color: AppColors.border),
                    _MetricItem(label: 'Completed', count: _controller.completedProjects),
                  ],
                ),
              ),

              // Search Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  onChanged: _controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search projects by title or topic...',
                    hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              _controller.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Status Chips
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _statuses.length,
                  itemBuilder: (ctx, i) {
                    final s = _statuses[i];
                    final isSelected = _controller.statusFilter == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(s),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 1,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) _controller.setFilter(s);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Projects List
              Expanded(
                child: projects.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border, width: 1),
                                ),
                                child: const Icon(Icons.rocket_launch_outlined, size: 48, color: AppColors.textTertiary),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _controller.searchQuery.isNotEmpty
                                    ? 'No projects matching "${_controller.searchQuery}"'
                                    : 'No initiatives yet.\nStart a project to plan trips, events, or shared ideas together!',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: projects.length,
                        itemBuilder: (ctx, i) {
                          final p = projects[i];
                          return ProjectCard(
                            project: p,
                            onTap: () => _showProjectDetails(p),
                            onEdit: () => _showCreateEditSheet(p),
                            onDelete: () => _confirmDelete(p),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final int count;

  const _MetricItem({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
