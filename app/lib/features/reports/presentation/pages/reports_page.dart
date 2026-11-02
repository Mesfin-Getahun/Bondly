import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/reports_controller.dart';
import '../widgets/reports_widget.dart';

/// Feature: Reports - Main Page
///
/// User reports, community moderation flags, and safety requests.
class ReportsPage extends StatefulWidget {
  final String? currentUserId;
  final String? currentUserName;
  final ReportsController? controller;

  const ReportsPage({
    super.key,
    this.currentUserId,
    this.currentUserName,
    this.controller,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late final ReportsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ReportsController();
    if (widget.currentUserId != null) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void didUpdateWidget(covariant ReportsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUserId != null && widget.currentUserId != oldWidget.currentUserId) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showSubmitReportSheet() {
    final userId = widget.currentUserId ?? '';
    final userName = widget.currentUserName ?? 'Anonymous';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SubmitReportSheet(
        controller: _controller,
        reporterId: userId,
        reporterName: userName,
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
        shape: const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        title: const Text(
          'Safety & Reports',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.report_problem_outlined),
        label: const Text('File Report', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showSubmitReportSheet,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.reports.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = _controller.reports;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Safety Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.privacySurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.privacyBorder, width: 1),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.privacyAccent.withAlpha(35),
                      child: const Icon(Icons.shield_outlined, color: AppColors.privacyAccent, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bondly Safety & Moderation',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Reports are strictly confidential and reviewed by moderators to protect user safety.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Your Filed Reports',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),

              if (reports.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 56, color: Colors.greenAccent),
                        SizedBox(height: 14),
                        Text(
                          'No reports filed.\nThank you for helping keep our community friendly and safe!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...reports.map((r) => ReportTile(report: r)),
            ],
          );
        },
      ),
    );
  }
}
