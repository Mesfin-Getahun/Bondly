import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/invitations_controller.dart';
import '../widgets/invitations_widget.dart';

/// Feature: Invitations - Main Page
///
/// Manages private invitation links and codes to connect with
/// friends, colleagues, and family.
class InvitationsPage extends StatefulWidget {
  final String? currentUserId;
  final String? currentUserName;
  final InvitationsController? controller;

  const InvitationsPage({
    super.key,
    this.currentUserId,
    this.currentUserName,
    this.controller,
  });

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> with SingleTickerProviderStateMixin {
  late final InvitationsController _controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? InvitationsController();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.currentUserId != null) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void didUpdateWidget(covariant InvitationsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUserId != null && widget.currentUserId != oldWidget.currentUserId) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showCreateSheet() {
    if (widget.currentUserId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CreateInvitationSheet(
        controller: _controller,
        senderId: widget.currentUserId!,
        senderName: widget.currentUserName ?? 'A Friend',
      ),
    );
  }

  void _showRedeemSheet() {
    if (widget.currentUserId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RedeemInvitationSheet(
        controller: _controller,
        recipientId: widget.currentUserId!,
        recipientName: widget.currentUserName ?? 'A Friend',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Invitations', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: _showRedeemSheet,
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
            label: const Text('Redeem Code'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.vpn_key_outlined), text: 'Active Codes'),
            Tab(icon: Icon(Icons.history_rounded), text: 'History & Claimed'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_link_rounded),
        label: const Text('New Invite'),
        onPressed: _showCreateSheet,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.invitations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeList = _controller.activeInvitations;
          final historyList = _controller.historyInvitations;

          return Column(
            children: [
              // Metric Summary Header
              Container(
                margin: const EdgeInsets.all(16),
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
                    _MetricItem(label: 'Total Generated', count: _controller.totalCount),
                    Container(height: 30, width: 1, color: Colors.white24),
                    _MetricItem(label: 'Active Codes', count: _controller.activeCount),
                    Container(height: 30, width: 1, color: Colors.white24),
                    _MetricItem(label: 'Redeemed', count: _controller.claimedCount),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Active Codes Tab
                    _InvitationList(
                      invitations: activeList,
                      emptyMessage: 'No active invitation codes.\nTap "New Invite" to generate one!',
                      emptyIcon: Icons.vpn_key_outlined,
                      onRevoke: (id) => _controller.revoke(id),
                    ),

                    // History & Claimed Tab
                    _InvitationList(
                      invitations: historyList,
                      emptyMessage: 'No past or claimed invitations yet.',
                      emptyIcon: Icons.history_rounded,
                      onRevoke: (id) => _controller.revoke(id),
                    ),
                  ],
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

class _InvitationList extends StatelessWidget {
  final List invitations;
  final String emptyMessage;
  final IconData emptyIcon;
  final void Function(String id) onRevoke;

  const _InvitationList({
    required this.invitations,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(emptyIcon, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: invitations.length,
      itemBuilder: (context, index) {
        final inv = invitations[index];
        return InvitationTile(
          invitation: inv,
          onRevoke: () => onRevoke(inv.id),
        );
      },
    );
  }
}
