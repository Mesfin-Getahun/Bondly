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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
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
          // Top Row: Reason + Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.error.withAlpha(30),
                    child: const Icon(Icons.shield_outlined, size: 18, color: AppColors.error),
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
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withAlpha(90)),
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
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
          ],

          Text(
            report.description,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
          ),

          if (report.resolutionNotes?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'Moderation Response: ${report.resolutionNotes}',
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),

          Text(
            'Submitted ${AppDateUtils.formatShortDate(report.createdAt)} (${AppDateUtils.timeAgo(report.createdAt)})',
            style: const TextStyle(fontSize: 11, color: AppColors.microLabel),
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
                    'Report a Concern',
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
                'Help keep Bondly safe. All reports are strictly confidential.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Reason selection chips
              const Text(
                'What is the issue?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary),
              ),
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
                    backgroundColor: AppColors.surfaceElevated,
                    side: BorderSide(
                      color: isSelected ? AppColors.error : AppColors.border,
                      width: 1,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
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
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'User or Group Name (Optional)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'e.g. Alex Carter',
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
                    borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Detailed Description
              TextFormField(
                controller: _descController,
                maxLines: 4,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Description of the incident *',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'Please describe what happened in as much detail as possible...',
                  hintStyle: const TextStyle(color: AppColors.microLabel),
                  prefixIcon: const Icon(Icons.notes_rounded, color: AppColors.textSecondary),
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
                    borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                  ),
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
