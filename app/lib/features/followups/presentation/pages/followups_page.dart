import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/presentation/widgets/dashboard_widget.dart';
import '../../domain/entities/followups_entity.dart';
import '../controllers/followups_controller.dart';
import '../widgets/followups_widget.dart';

/// Feature: Followups - Main Page
///
/// CRITICAL PRIVACY REQUIREMENT:
/// All reminders on this page belong strictly to the authenticated user.
/// Adheres strictly to AGENTS.md dark modern styling and privacy standards.
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
      backgroundColor: Colors.transparent,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Follow-ups & Reminders',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Reminder',
            icon: const Icon(Icons.add_alert_rounded, color: AppColors.textPrimary),
            onPressed: () => _showAddFollowupSheet(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.microLabel,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
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
                              fontSize: 10,
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
          return Column(
            children: [
              // AGENTS.md Rule 4: Privacy Status Component
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: PrivacyStatusBanner(),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  onChanged: _controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search reminders or contacts...',
                    hintStyle: const TextStyle(color: AppColors.microLabel, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              _controller.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              ),

              // Tab Views
              Expanded(
                child: _controller.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(_controller.upcomingFollowups, 'No upcoming follow-ups scheduled.'),
                          _buildList(
                            _controller.dueTodayOrOverdue,
                            'All caught up! No overdue reminders for today.',
                            isUrgentTab: true,
                          ),
                          _buildList(_controller.completedFollowups, 'No completed follow-ups yet.'),
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
        elevation: 4,
        onPressed: () => _showAddFollowupSheet(),
        icon: const Icon(Icons.alarm_add_rounded),
        label: const Text('Add Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildList(List<FollowupEntity> items, String emptyMessage, {bool isUrgentTab = false}) {
    if (items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isUrgentTab
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUrgentTab
                        ? const Color(0xFF10B981).withValues(alpha: 0.3)
                        : AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isUrgentTab ? Icons.check_circle_outline_rounded : Icons.alarm_rounded,
                  size: 36,
                  color: isUrgentTab ? const Color(0xFF10B981) : AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return FollowupTile(
          followup: item,
          onToggle: (val) => _controller.toggleComplete(item.id, val ?? false),
          onDelete: () => _controller.deleteFollowup(item.id),
          onEdit: () => _showAddFollowupSheet(item),
        );
      },
    );
  }
}
