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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Invitations',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _showRedeemSheet,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.primary.withAlpha(25),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
              label: const Text('Redeem Code', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(icon: Icon(Icons.vpn_key_outlined, size: 20), text: 'Active Codes'),
                Tab(icon: Icon(Icons.history_rounded, size: 20), text: 'History & Claimed'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_link_rounded),
        label: const Text('New Invite', style: TextStyle(fontWeight: FontWeight.bold)),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MetricItem(label: 'Total Generated', count: _controller.totalCount, color: AppColors.textPrimary),
                    Container(height: 32, width: 1, color: AppColors.border),
                    _MetricItem(label: 'Active Codes', count: _controller.activeCount, color: AppColors.primary),
                    Container(height: 32, width: 1, color: AppColors.border),
                    _MetricItem(label: 'Redeemed', count: _controller.claimedCount, color: Colors.greenAccent),
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
  final Color color;

  const _MetricItem({
    required this.label,
    required this.count,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
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
              Icon(emptyIcon, size: 56, color: AppColors.microLabel),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
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
