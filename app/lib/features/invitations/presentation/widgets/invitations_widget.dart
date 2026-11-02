import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/invitations_entity.dart';
import '../controllers/invitations_controller.dart';

/// Feature: Invitations - Tile display for a sent invitation
class InvitationTile extends StatelessWidget {
  final InvitationEntity invitation;
  final VoidCallback onRevoke;

  const InvitationTile({
    super.key,
    required this.invitation,
    required this.onRevoke,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'revoked':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      case 'pending':
      default:
        return AppColors.primary;
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = invitation.effectiveStatus;
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: invitation.isPending ? AppColors.primary.withAlpha(70) : AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Code Badge + Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Invitation Code Box
              InkWell(
                onTap: () => _copyToClipboard(context, invitation.code, 'Code'),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.vpn_key_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        invitation.code,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1.2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ),

              // Status Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withAlpha(80)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Invitee or Relationship info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  invitation.relationshipType,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (invitation.inviteeName != null) ...[
                const SizedBox(width: 8),
                Text(
                  'for ${invitation.inviteeName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),

          if (invitation.personalNote != null) ...[
            const SizedBox(height: 8),
            Text(
              '"${invitation.personalNote}"',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Bottom Row: Expiration / Claimed Details + Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (invitation.isClaimed && invitation.claimedByName != null) ...[
                      Text(
                        'Claimed by ${invitation.claimedByName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.greenAccent,
                        ),
                      ),
                      if (invitation.claimedAt != null)
                        Text(
                          AppDateUtils.timeAgo(invitation.claimedAt!),
                          style: const TextStyle(fontSize: 11, color: AppColors.microLabel),
                        ),
                    ] else if (invitation.isPending) ...[
                      Text(
                        'Expires: ${AppDateUtils.formatShortDate(invitation.expiresAt)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ] else ...[
                      Text(
                        'Created: ${AppDateUtils.formatShortDate(invitation.createdAt)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.microLabel),
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Copy Link',
                    icon: const Icon(Icons.link_rounded, size: 20, color: AppColors.primary),
                    onPressed: () => _copyToClipboard(
                      context,
                      invitation.shareUrl,
                      'Invite link',
                    ),
                  ),
                  if (invitation.isPending)
                    IconButton(
                      tooltip: 'Revoke Invite',
                      icon: const Icon(Icons.cancel_outlined, size: 20, color: Colors.redAccent),
                      onPressed: onRevoke,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Feature: Invitations - Bottom sheet to generate a new invitation code
class CreateInvitationSheet extends StatefulWidget {
  final InvitationsController controller;
  final String senderId;
  final String senderName;

  const CreateInvitationSheet({
    super.key,
    required this.controller,
    required this.senderId,
    required this.senderName,
  });

  @override
  State<CreateInvitationSheet> createState() => _CreateInvitationSheetState();
}

class _CreateInvitationSheetState extends State<CreateInvitationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();

  String _relationshipType = 'Friend';
  int _validityDays = 14;

  final _relationships = ['Friend', 'Bestie', 'Family', 'Colleague', 'Partner', 'Mentor'];
  final _validityOptions = [
    {'days': 7, 'label': '7 Days'},
    {'days': 14, 'label': '14 Days'},
    {'days': 30, 'label': '30 Days'},
    {'days': 90, 'label': '90 Days'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final inv = await widget.controller.createNewInvitation(
      senderId: widget.senderId,
      senderName: widget.senderName,
      inviteeName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
      inviteeEmail: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      relationshipType: _relationshipType,
      personalNote: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      validityDays: _validityDays,
    );

    if (mounted) {
      Navigator.pop(context);
      if (inv != null) {
        Clipboard.setData(ClipboardData(text: inv.code));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created code ${inv.code}! Copied to clipboard.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Generate Private Invite',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Generate a private code or link to invite someone to connect on Bondly.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Relationship Type Chips
              const Text(
                'Relationship Type',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _relationships.map((rel) {
                  final isSelected = _relationshipType == rel;
                  return ChoiceChip(
                    label: Text(rel),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceElevated,
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
                      if (val) setState(() => _relationshipType = rel);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Optional Invitee Name
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Invitee Name (Optional)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'e.g. Sarah Jenkins',
                  hintStyle: const TextStyle(color: AppColors.microLabel),
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Optional Invitee Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Invitee Email (Optional)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'sarah@example.com',
                  hintStyle: const TextStyle(color: AppColors.microLabel),
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Validity selector
              DropdownButtonFormField<int>(
                initialValue: _validityDays,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Code Validity Period',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.timer_outlined, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                items: _validityOptions
                    .map((opt) => DropdownMenuItem(
                          value: opt['days'] as int,
                          child: Text(
                            opt['label'] as String,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _validityDays = v);
                },
              ),
              const SizedBox(height: 12),

              // Personal Note
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Personal Welcome Note (Optional)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'Hey! Join me on Bondly so we can stay in touch.',
                  hintStyle: const TextStyle(color: AppColors.microLabel),
                  prefixIcon: const Icon(Icons.message_outlined, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.vpn_key_rounded),
                label: const Text(
                  'Create Private Code',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feature: Invitations - Sheet to redeem an invitation code
class RedeemInvitationSheet extends StatefulWidget {
  final InvitationsController controller;
  final String recipientId;
  final String recipientName;

  const RedeemInvitationSheet({
    super.key,
    required this.controller,
    required this.recipientId,
    required this.recipientName,
  });

  @override
  State<RedeemInvitationSheet> createState() => _RedeemInvitationSheetState();
}

class _RedeemInvitationSheetState extends State<RedeemInvitationSheet> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      String text = data.text!.trim().toUpperCase();
      if (text.startsWith('HTTPS://BONDLY.APP/INVITE/')) {
        text = text.replaceFirst('HTTPS://BONDLY.APP/INVITE/', '');
      }
      setState(() {
        _codeController.text = text;
      });
    }
  }

  void _redeem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final nav = Navigator.of(context);
    final scaffold = ScaffoldMessenger.of(context);

    final success = await widget.controller.redeemInvitation(
      code: _codeController.text.trim().toUpperCase(),
      recipientId: widget.recipientId,
      recipientName: widget.recipientName,
    );

    setState(() => _isSubmitting = false);

    if (success) {
      nav.pop();
      scaffold.showSnackBar(
        SnackBar(
          content: Text(widget.controller.successMessage ?? 'Invitation redeemed successfully!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      scaffold.showSnackBar(
        SnackBar(
          content: Text(widget.controller.errorMessage ?? 'Failed to redeem invitation.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Redeem Invitation Code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter a 5-digit Bondly invitation code or link to connect immediately.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),

              // Code input
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppColors.primary,
                ),
                decoration: InputDecoration(
                  labelText: 'Invitation Code',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'BOND-XXXXX',
                  hintStyle: const TextStyle(color: AppColors.microLabel),
                  prefixIcon: const Icon(Icons.qr_code_rounded, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    tooltip: 'Paste from clipboard',
                    icon: const Icon(Icons.content_paste_rounded, color: AppColors.primary),
                    onPressed: _pasteFromClipboard,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter an invitation code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.privacySurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.privacyBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, color: AppColors.privacyAccent, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Redeeming connects you with the inviter so you can message each other directly and privately.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _redeem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Redeem & Connect',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
