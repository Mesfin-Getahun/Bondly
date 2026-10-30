import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/relationships_entity.dart';
import '../controllers/relationships_controller.dart';
import '../widgets/relationships_widget.dart';

/// Feature: Relationships - Main Page
///
/// CRITICAL PRIVACY REQUIREMENT:
/// All data shown on this page belongs strictly to the authenticated user.
class RelationshipsPage extends StatefulWidget {
  final String? userId;
  final RelationshipsController? controller;

  const RelationshipsPage({super.key, this.userId, this.controller});

  @override
  State<RelationshipsPage> createState() => _RelationshipsPageState();
}

class _RelationshipsPageState extends State<RelationshipsPage> {
  late final RelationshipsController _controller;
  final _searchController = TextEditingController();

  final _categories = ['All', 'Bestie', 'Friend', 'Family', 'Colleague', 'Mentor'];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RelationshipsController();
    if (widget.userId != null) {
      _controller.init(widget.userId!);
    }
  }

  @override
  void didUpdateWidget(covariant RelationshipsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != null && widget.userId != oldWidget.userId) {
      _controller.init(widget.userId!);
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

  void _showAddSheet([RelationshipEntity? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddEditRelationshipSheet(
        controller: _controller,
        existing: existing,
      ),
    );
  }

  void _showLogInteractionSheet(RelationshipEntity relationship) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LogInteractionSheet(
        controller: _controller,
        relationship: relationship,
      ),
    );
  }

  void _showDetailSheet(RelationshipEntity relationship) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _RelationshipDetailSheet(
        relationship: relationship,
        controller: _controller,
        onEdit: () {
          Navigator.pop(context);
          _showAddSheet(relationship);
        },
        onLogInteraction: () {
          Navigator.pop(context);
          _showLogInteractionSheet(relationship);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Relationships', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Add Contact',
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => _showAddSheet(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final list = _controller.filteredRelationships;
          final dueCount = _controller.dueCount;

          return Column(
            children: [
              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search by name, nickname, or tags...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _controller.setSearchQuery('');
                            },
                          )
                        : null,
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

              // Filter Chips
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Due Follow-ups Chip
                    if (dueCount > 0) ...[
                      FilterChip(
                        selected: _controller.filterDueOnly,
                        avatar: const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.white),
                        label: Text('Due ($dueCount)'),
                        selectedColor: AppColors.error,
                        backgroundColor: AppColors.error.withAlpha(20),
                        labelStyle: TextStyle(
                          color: _controller.filterDueOnly ? Colors.white : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => _controller.toggleFilterDueOnly(),
                      ),
                      const SizedBox(width: 8),
                    ],

                    ..._categories.map((cat) {
                      final isSelected = _controller.selectedType == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: isSelected,
                          label: Text(cat),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) _controller.setSelectedType(cat);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Contacts List or Empty State
              Expanded(
                child: _controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : list.isEmpty
                        ? _EmptyRelationshipsView(onAddContact: () => _showAddSheet())
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final rel = list[index];
                              return RelationshipCard(
                                relationship: rel,
                                onTap: () => _showDetailSheet(rel),
                                onLogInteraction: () => _showLogInteractionSheet(rel),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showAddSheet(),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Contact', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// Empty state display
class _EmptyRelationshipsView extends StatelessWidget {
  final VoidCallback onAddContact;

  const _EmptyRelationshipsView({required this.onAddContact});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Private Contacts Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add the people who matter most to you to track interactions, private notes, and automatic follow-up reminders.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add First Contact', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detailed bottom sheet for a contact (Interactions + Notes)
class _RelationshipDetailSheet extends StatefulWidget {
  final RelationshipEntity relationship;
  final RelationshipsController controller;
  final VoidCallback onEdit;
  final VoidCallback onLogInteraction;

  const _RelationshipDetailSheet({
    required this.relationship,
    required this.controller,
    required this.onEdit,
    required this.onLogInteraction,
  });

  @override
  State<_RelationshipDetailSheet> createState() => _RelationshipDetailSheetState();
}

class _RelationshipDetailSheetState extends State<_RelationshipDetailSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    await widget.controller.addNote(
      relationshipId: widget.relationship.id,
      content: text,
    );
    _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final rel = widget.relationship;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withAlpha(25),
                      child: Text(
                        rel.name.isNotEmpty ? rel.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rel.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (rel.nickname != null)
                            Text('"${rel.nickname}"', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          Text(
                            rel.relationshipType,
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: widget.onEdit,
                      tooltip: 'Edit Contact',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      tooltip: 'Delete Contact',
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Contact'),
                            content: Text('Are you sure you want to delete ${rel.name}?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await widget.controller.deleteRelationship(rel.id);
                          nav.pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(icon: Icon(Icons.history_rounded, size: 20), text: 'Interactions'),
                  Tab(icon: Icon(Icons.note_alt_outlined, size: 20), text: 'Private Notes'),
                ],
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Interactions Tab
                    StreamBuilder<List<InteractionLogEntity>>(
                      stream: widget.controller.watchInteractions(rel.id),
                      builder: (context, snapshot) {
                        final interactions = snapshot.data ?? [];
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (interactions.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('No interactions recorded yet.', style: TextStyle(color: Colors.grey)),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: widget.onLogInteraction,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Log First Interaction'),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: interactions.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final item = interactions[idx];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withAlpha(20),
                                child: const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 18),
                              ),
                              title: Text(item.summary, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(AppDateUtils.formatShortDate(item.date)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                                onPressed: () => widget.controller.deleteInteraction(rel.id, item.id),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // Private Notes Tab
                    Column(
                      children: [
                        Expanded(
                          child: StreamBuilder<List<RelationshipNoteEntity>>(
                            stream: widget.controller.watchNotes(rel.id),
                            builder: (context, snapshot) {
                              final notes = snapshot.data ?? [];
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (notes.isEmpty) {
                                return const Center(
                                  child: Text('No private notes yet. Add your thoughts below.', style: TextStyle(color: Colors.grey)),
                                );
                              }
                              return ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: notes.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 8),
                                itemBuilder: (context, idx) {
                                  final note = notes[idx];
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.amber.shade200),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(note.content, style: const TextStyle(fontSize: 14)),
                                              const SizedBox(height: 4),
                                              Text(
                                                AppDateUtils.formatShortDate(note.createdAt),
                                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                                          onPressed: () => widget.controller.deleteNote(rel.id, note.id),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        // Add Note Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border(top: BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _noteController,
                                  decoration: const InputDecoration(
                                    hintText: 'Add a private note...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                                onPressed: _addNote,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
