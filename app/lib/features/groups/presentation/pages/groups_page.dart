import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/groups_entity.dart';
import '../controllers/groups_controller.dart';
import '../widgets/groups_widget.dart';

/// Feature: Groups - Main Page
///
/// Circles, memberships, collaborative groupings, and group roles.
class GroupsPage extends StatefulWidget {
  final String? currentUserId;
  final String? currentUserName;
  final GroupsController? controller;

  const GroupsPage({
    super.key,
    this.currentUserId,
    this.currentUserName,
    this.controller,
  });

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late final GroupsController _controller;
  final _searchController = TextEditingController();

  final _categories = ['All', 'Friends', 'Family', 'Work', 'Hobbies', 'Community', 'Other'];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? GroupsController();
    if (widget.currentUserId != null) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void didUpdateWidget(covariant GroupsPage oldWidget) {
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

  void _showCreateEditSheet([GroupEntity? existing]) {
    final userId = widget.currentUserId ?? '';
    final userName = widget.currentUserName ?? 'Me';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CreateEditGroupSheet(
        controller: _controller,
        currentUserId: userId,
        currentUserName: userName,
        existing: existing,
      ),
    );
  }

  void _showMembersSheet(GroupEntity group) {
    final userId = widget.currentUserId ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => GroupMembersSheet(
        controller: _controller,
        group: group,
        currentUserId: userId,
      ),
    );
  }

  void _confirmDeleteOrLeave(GroupEntity group) {
    final isOwner = widget.currentUserId != null && group.isOwner(widget.currentUserId!);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isOwner ? 'Delete Circle?' : 'Leave Circle?'),
        content: Text(
          isOwner
            ? 'Are you sure you want to permanently delete "${group.name}"? This will remove all members.'
            : 'Are you sure you want to leave "${group.name}"?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              if (isOwner) {
                await _controller.deleteCircle(group.id);
              } else if (widget.currentUserId != null) {
                await _controller.removeMemberFromGroup(
                  groupId: group.id,
                  userId: widget.currentUserId!,
                );
              }
            },
            child: Text(isOwner ? 'Delete' : 'Leave', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.currentUserId ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Circles & Groups', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'New Circle',
            icon: const Icon(Icons.group_add_outlined),
            onPressed: () => _showCreateEditSheet(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Circle'),
        onPressed: () => _showCreateEditSheet(),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.groups.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final groups = _controller.filteredGroups;

          return Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search circles by name or topic...',
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

              // Category filters
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final isSelected = _controller.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) _controller.setCategory(cat);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // List of Circles
              Expanded(
                child: groups.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.diversity_3_outlined, size: 60, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                _controller.searchQuery.isNotEmpty
                                    ? 'No circles matching "${_controller.searchQuery}"'
                                    : 'No circles yet.\nCreate a circle to organize close friends, colleagues, or family!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: groups.length,
                        itemBuilder: (ctx, i) {
                          final g = groups[i];
                          return GroupCard(
                            group: g,
                            currentUserId: userId,
                            onTap: () => _showMembersSheet(g),
                            onEdit: () => _showCreateEditSheet(g),
                            onManageMembers: () => _showMembersSheet(g),
                            onLeaveOrDelete: () => _confirmDeleteOrLeave(g),
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
