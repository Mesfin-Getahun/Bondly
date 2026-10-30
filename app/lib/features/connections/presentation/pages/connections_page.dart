import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../messaging/data/repositories/messaging_repository_impl.dart';
import '../../../messaging/domain/usecases/get_messaging_usecase.dart';
import '../../../messaging/presentation/controllers/messaging_controller.dart';
import '../../../messaging/presentation/pages/chat_conversation_page.dart';
import '../../domain/entities/connections_entity.dart';
import '../controllers/connections_controller.dart';
import '../widgets/connections_widget.dart';

/// Feature: Connections - Main Screen
class ConnectionsPage extends StatefulWidget {
  final String? currentUserId;
  final String? currentUserName;
  final ConnectionsController? controller;

  const ConnectionsPage({
    super.key,
    this.currentUserId,
    this.currentUserName,
    this.controller,
  });

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> with SingleTickerProviderStateMixin {
  late final ConnectionsController _controller;
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ConnectionsController();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.currentUserId != null) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void didUpdateWidget(covariant ConnectionsPage oldWidget) {
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

  void _showAddFriendSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SendRequestSheet(
        controller: _controller,
        currentUserName: widget.currentUserName ?? 'Me',
      ),
    );
  }

  void _startChatWithFriend(ConnectionEntity connection) async {
    if (widget.currentUserId == null) return;
    final otherId = connection.otherUserId(widget.currentUserId!);
    final otherName = connection.otherUserName(widget.currentUserId!);

    final messagingController = MessagingController(
      useCases: MessagingUseCases(MessagingRepositoryImpl()),
    );
    messagingController.init(widget.currentUserId!);

    final conv = await messagingController.openOrCreateChat(
      otherUserId: otherId,
      currentUserName: widget.currentUserName,
      otherUserName: otherName,
    );

    if (conv != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatConversationPage(
            conversation: conv,
            currentUserId: widget.currentUserId!,
            controller: messagingController,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.currentUserId ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Connections', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Add Friend',
            icon: const Icon(Icons.person_add_rounded),
            onPressed: _showAddFriendSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: [
            const Tab(text: 'Friends'),
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                final pending = _controller.pendingIncomingCount;
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Requests'),
                      if (pending > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$pending',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const Tab(text: 'Sent'),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final friends = _controller.acceptedFriends;
          final incoming = _controller.incomingRequests;
          final sent = _controller.sentRequests;

          return TabBarView(
            controller: _tabController,
            children: [
              // 1. Friends Tab
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _controller.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search friends...',
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
                  Expanded(
                    child: _controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : friends.isEmpty
                            ? _EmptyStateView(
                                icon: Icons.people_outline_rounded,
                                title: 'No Friends Connected Yet',
                                subtitle: 'Send a connection request to connect with friends on Bondly.',
                                actionLabel: 'Add Friend',
                                onAction: _showAddFriendSheet,
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: friends.length,
                                itemBuilder: (context, index) {
                                  final conn = friends[index];
                                  return FriendConnectionCard(
                                    connection: conn,
                                    currentUserId: userId,
                                    onMessage: () => _startChatWithFriend(conn),
                                    onRemove: () => _controller.removeConnection(conn.id),
                                    onBlock: () => _controller.blockUser(conn.id),
                                  );
                                },
                              ),
                  ),
                ],
              ),

              // 2. Incoming Requests Tab
              _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : incoming.isEmpty
                      ? const _EmptyStateView(
                          icon: Icons.mark_email_unread_outlined,
                          title: 'No Pending Requests',
                          subtitle: 'When friends send you a connection request, it will appear here.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: incoming.length,
                          itemBuilder: (context, index) {
                            final conn = incoming[index];
                            return IncomingRequestCard(
                              connection: conn,
                              currentUserId: userId,
                              onAccept: () => _controller.acceptRequest(conn.id),
                              onDecline: () => _controller.declineRequest(conn.id),
                            );
                          },
                        ),

              // 3. Sent Requests Tab
              _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : sent.isEmpty
                      ? const _EmptyStateView(
                          icon: Icons.send_outlined,
                          title: 'No Sent Requests',
                          subtitle: 'Friend requests you have sent to others will show here.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: sent.length,
                          itemBuilder: (context, index) {
                            final conn = sent[index];
                            return SentRequestCard(
                              connection: conn,
                              onCancel: () => _controller.removeConnection(conn.id),
                            );
                          },
                        ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _showAddFriendSheet,
        tooltip: 'Add Friend',
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyStateView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

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
              child: Icon(icon, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add),
                label: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
