import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/followups_entity.dart';
import '../controllers/followups_controller.dart';
import '../widgets/followups_widget.dart';

/// Feature: Followups - Main Page
///
/// CRITICAL PRIVACY REQUIREMENT:
/// All reminders on this page belong strictly to the authenticated user.
class FollowupsPage extends StatefulWidget {
  final String? currentUserId;
  final FollowupsController? controller;

  const FollowupsPage({super.key, this.currentUserId, this.controller});

  @override
  State<FollowupsPage> createState() => _FollowupsPageState();
}

class _FollowupsPageState extends State<FollowupsPage> with SingleTickerProviderStateMixin {
  late final FollowupsController _controller;
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? FollowupsController();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.currentUserId != null) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void didUpdateWidget(covariant FollowupsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUserId != null && widget.currentUserId != oldWidget.currentUserId) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showAddFollowupSheet([FollowupEntity? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddEditFollowupSheet(
        controller: _controller,
        existing: existing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Follow-ups & Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Add Reminder',
            icon: const Icon(Icons.add_alert_rounded),
            onPressed: () => _showAddFollowupSheet(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: [
            const Tab(text: 'Upcoming'),
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                final urgentCount = _controller.overdueCount + _controller.todayCount;
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Today & Due'),
                      if (urgentCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$urgentCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const Tab(text: 'Completed'),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final pending = _controller.pendingFollowups;
          final urgent = [
            ..._controller.overdueFollowups,
            ..._controller.todayFollowups,
          ];
          final completed = _controller.completedFollowups;

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search reminders by title or contact...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 1. Upcoming Tab
                    _controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : pending.isEmpty
                            ? _EmptyFollowupsView(onAdd: () => _showAddFollowupSheet())
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: pending.length,
                                itemBuilder: (context, idx) {
                                  final item = pending[idx];
                                  return FollowupTile(
                                    followup: item,
                                    onToggle: (val) => _controller.toggleComplete(item.id, val ?? false),
                                    onDelete: () => _controller.deleteFollowup(item.id),
                                    onEdit: () => _showAddFollowupSheet(item),
                                  );
                                },
                              ),

                    // 2. Urgent / Today Tab
                    _controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : urgent.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Text(
                                    '🎉 All caught up! No overdue or today reminders.',
                                    style: TextStyle(color: Colors.grey, fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: urgent.length,
                                itemBuilder: (context, idx) {
                                  final item = urgent[idx];
                                  return FollowupTile(
                                    followup: item,
                                    onToggle: (val) => _controller.toggleComplete(item.id, val ?? false),
                                    onDelete: () => _controller.deleteFollowup(item.id),
                                    onEdit: () => _showAddFollowupSheet(item),
                                  );
                                },
                              ),

                    // 3. Completed Tab
                    _controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : completed.isEmpty
                            ? const Center(
                                child: Text('No completed follow-ups yet.', style: TextStyle(color: Colors.grey)),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: completed.length,
                                itemBuilder: (context, idx) {
                                  final item = completed[idx];
                                  return FollowupTile(
                                    followup: item,
                                    onToggle: (val) => _controller.toggleComplete(item.id, val ?? false),
                                    onDelete: () => _controller.deleteFollowup(item.id),
                                  );
                                },
                              ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showAddFollowupSheet(),
        icon: const Icon(Icons.alarm_add_rounded),
        label: const Text('Add Follow-up', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _EmptyFollowupsView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyFollowupsView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary.withAlpha(20),
              child: const Icon(Icons.alarm_rounded, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Scheduled Follow-ups',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Set recurring reminders to stay in touch with friends, celebrate milestones, and never lose contact.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Schedule Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
