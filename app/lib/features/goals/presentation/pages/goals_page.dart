import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/goals_entity.dart';
import '../controllers/goals_controller.dart';
import '../widgets/goals_widget.dart';

/// Feature: Goals - Main Page
///
/// Personal and shared relationship goals, habit milestones, and collaborative targets.
class GoalsPage extends StatefulWidget {
  final String? currentUserId;
  final String? currentUserName;
  final GoalsController? controller;

  const GoalsPage({
    super.key,
    this.currentUserId,
    this.currentUserName,
    this.controller,
  });

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  late final GoalsController _controller;
  final _searchController = TextEditingController();

  final _filters = ['All', 'Active', 'Personal', 'Shared', 'Completed'];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? GoalsController();
    if (widget.currentUserId != null) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void didUpdateWidget(covariant GoalsPage oldWidget) {
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

  void _showCreateEditSheet([GoalEntity? existing]) {
    final userId = widget.currentUserId ?? '';
    final userName = widget.currentUserName ?? 'Me';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CreateEditGoalSheet(
        controller: _controller,
        currentUserId: userId,
        currentUserName: userName,
        existing: existing,
      ),
    );
  }

  void _confirmDelete(GoalEntity goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _controller.delete(goal.id);
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
        title: const Text('Relationship Goals', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Add Goal',
            icon: const Icon(Icons.add_task_rounded),
            onPressed: () => _showCreateEditSheet(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.flag_rounded),
        label: const Text('New Goal'),
        onPressed: () => _showCreateEditSheet(),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.goals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final goals = _controller.filteredGoals;

          return Column(
            children: [
              // Summary Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(50),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryMetric(label: 'Total Goals', count: _controller.totalCount),
                    Container(height: 30, width: 1, color: Colors.white24),
                    _SummaryMetric(label: 'In Progress', count: _controller.activeCount),
                    Container(height: 30, width: 1, color: Colors.white24),
                    _SummaryMetric(label: 'Completed', count: _controller.completedCount),
                  ],
                ),
              ),

              // Search & Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: _controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search goals...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
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

              // Filter Chips
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  itemBuilder: (ctx, i) {
                    final f = _filters[i];
                    final isSelected = _controller.filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) _controller.setFilter(f);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // List of Goals
              Expanded(
                child: goals.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.flag_outlined, size: 60, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                _controller.searchQuery.isNotEmpty
                                    ? 'No goals matching "${_controller.searchQuery}"'
                                    : 'No goals in this category.\nSet a goal to keep your friendships thriving!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: goals.length,
                        itemBuilder: (ctx, i) {
                          final g = goals[i];
                          return GoalCard(
                            goal: g,
                            onIncrement: () => _controller.increment(g.id),
                            onToggleComplete: (val) => _controller.toggleCompletion(g.id, val),
                            onEdit: () => _showCreateEditSheet(g),
                            onDelete: () => _confirmDelete(g),
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

class _SummaryMetric extends StatelessWidget {
  final String label;
  final int count;

  const _SummaryMetric({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
