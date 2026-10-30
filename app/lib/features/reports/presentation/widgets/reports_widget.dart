import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/reports_entity.dart';
import '../controllers/reports_controller.dart';

/// Feature: Reports - Tile Widget
class ReportTile extends StatelessWidget {
  final ReportEntity report;

  const ReportTile({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final statusColor = report.statusColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Reason + Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.red.shade50,
                    child: Icon(Icons.shield_outlined, size: 18, color: Colors.red.shade700),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    report.reason,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withAlpha(60)),
                ),
                child: Text(
                  report.statusLabel.toUpperCase(),
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
          const SizedBox(height: 10),

          if (report.targetUserName?.isNotEmpty == true) ...[
            Text(
              'Reported Entity: ${report.targetUserName}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
          ],

          Text(
            report.description,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
          ),

          if (report.resolutionNotes?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                'Moderation Response: ${report.resolutionNotes}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          Text(
            'Submitted ${AppDateUtils.formatShortDate(report.createdAt)} (${AppDateUtils.timeAgo(report.createdAt)})',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

/// Feature: Reports - Submit Report Sheet
class SubmitReportSheet extends StatefulWidget {
  final ReportsController controller;
  final String reporterId;
  final String reporterName;
  final String? prefilledTargetUserId;
  final String? prefilledTargetUserName;

  const SubmitReportSheet({
    super.key,
    required this.controller,
    required this.reporterId,
    required this.reporterName,
    this.prefilledTargetUserId,
    this.prefilledTargetUserName,
  });

  @override
  State<SubmitReportSheet> createState() => _SubmitReportSheetState();
}

class _SubmitReportSheetState extends State<SubmitReportSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _targetNameController;
  late final TextEditingController _descController;
  bool _isSubmitting = false;

  String _reason = 'Harassment';
  final _reasons = [
    'Harassment',
    'Spam / Scam',
    'Impersonation',
    'Inappropriate Content',
    'Privacy Breach',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _targetNameController = TextEditingController(text: widget.prefilledTargetUserName ?? '');
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _targetNameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final nav = Navigator.of(context);
    final scaffold = ScaffoldMessenger.of(context);

    final success = await widget.controller.createReport(
      reporterId: widget.reporterId,
      reporterName: widget.reporterName,
      targetUserId: widget.prefilledTargetUserId,
      targetUserName: _targetNameController.text.trim().isNotEmpty
          ? _targetNameController.text.trim()
          : null,
      reason: _reason,
      description: _descController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (success) {
      nav.pop();
      scaffold.showSnackBar(
        SnackBar(
          content: Text(widget.controller.successMessage ?? 'Report submitted.'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    'Report a Concern',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Help keep Bondly safe. All reports are strictly confidential.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // Reason selection chips
              const Text('What is the issue?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _reasons.map((r) {
                  final isSelected = _reason == r;
                  return ChoiceChip(
                    label: Text(r),
                    selected: isSelected,
                    selectedColor: AppColors.error,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _reason = r);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Target User / Entity Name
              TextFormField(
                controller: _targetNameController,
                decoration: const InputDecoration(
                  labelText: 'User or Group Name (Optional)',
                  hintText: 'e.g. Alex Carter',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),

              // Detailed Description
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description of the incident *',
                  hintText: 'Please describe what happened in as much detail as possible...',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                validator: (v) => v == null || v.trim().length < 5
                    ? 'Please provide a brief description (at least 5 characters)'
                    : null,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
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
                        'Submit Confidential Report',
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
