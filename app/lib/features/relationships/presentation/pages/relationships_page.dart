import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../dashboard/presentation/widgets/dashboard_widget.dart';
import '../../domain/entities/relationships_entity.dart';
import '../controllers/relationships_controller.dart';
import '../widgets/relationships_widget.dart';

/// Feature: Relationships - Main Page
///
/// CRITICAL PRIVACY REQUIREMENT:
/// All data shown on this page belongs strictly to the authenticated user.
/// Adheres strictly to AGENTS.md dark modern styling and privacy standards.
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
      backgroundColor: Colors.transparent,
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
      backgroundColor: Colors.transparent,
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
      backgroundColor: Colors.transparent,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Relationships',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Contact',
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.textPrimary),
            onPressed: () => _showAddSheet(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final list = _controller.filteredRelationships;
          final dueCount = _controller.dueCount;

          return Column(
            children: [
              // AGENTS.md Rule 4: Privacy Status Component for confidential records
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: PrivacyStatusBanner(),
              ),

              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  onChanged: _controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search by name, nickname, or tags...',
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

              // Filter Chips
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Due Follow-ups Chip
                    if (dueCount > 0) ...[
                      FilterChip(
                        selected: _controller.filterDueOnly,
                        avatar: const Icon(Icons.warning_amber_rounded, size: 15, color: Colors.white),
                        label: Text('Due ($dueCount)'),
                        selectedColor: AppColors.error,
                        backgroundColor: AppColors.error.withValues(alpha: 0.15),
                        side: BorderSide(
                          color: _controller.filterDueOnly ? AppColors.error : AppColors.error.withValues(alpha: 0.4),
                          width: 1,
                        ),
                        labelStyle: TextStyle(
                          color: _controller.filterDueOnly ? Colors.white : AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                          backgroundColor: AppColors.surface,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: 1,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
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
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : list.isEmpty
                        ? _EmptyRelationshipsView(onAddContact: () => _showAddSheet())
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
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
      floatingActionButton: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.filteredRelationships.isEmpty) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            onPressed: () => _showAddSheet(),
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Add Contact', style: TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }
}

/// Empty state display in Dark Modern Theme
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
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 38,
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
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add First Contact', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detailed bottom sheet for a contact (Interactions + Notes) in Dark Modern Theme
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
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        rel.name.isNotEmpty ? rel.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 20,
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (rel.nickname != null)
                            Text(
                              '"${rel.nickname}"',
                              style: const TextStyle(color: AppColors.microLabel, fontSize: 13),
                            ),
                          Text(
                            rel.relationshipType,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
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
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: const BorderSide(color: AppColors.border, width: 1),
                            ),
                            title: const Text('Delete Contact', style: TextStyle(color: AppColors.textPrimary)),
                            content: Text(
                              'Are you sure you want to delete ${rel.name}?',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  elevation: 0,
                                ),
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
              const Divider(color: AppColors.border, height: 1),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.microLabel,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.tab,
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
                          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                        }
                        if (interactions.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'No interactions recorded yet.',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: widget.onLogInteraction,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
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
                          separatorBuilder: (_, _) => const Divider(color: AppColors.border, height: 1),
                          itemBuilder: (context, idx) {
                            final item = interactions[idx];
                            return ListTile(
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 18),
                              ),
                              title: Text(
                                item.summary,
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                              subtitle: Text(
                                AppDateUtils.formatShortDate(item.date),
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.microLabel),
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
                                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                              }
                              if (notes.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No private notes yet. Add your thoughts below.',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
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
                                      color: AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppColors.border, width: 1),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                note.content,
                                                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                AppDateUtils.formatShortDate(note.createdAt),
                                                style: const TextStyle(fontSize: 11, color: AppColors.microLabel),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
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
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceElevated,
                            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _noteController,
                                  style: const TextStyle(color: AppColors.textPrimary),
                                  decoration: const InputDecoration(
                                    hintText: 'Add a private note...',
                                    hintStyle: TextStyle(color: AppColors.microLabel),
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
