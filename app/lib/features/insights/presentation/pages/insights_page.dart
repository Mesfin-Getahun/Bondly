import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/insights_controller.dart';
import '../widgets/insights_widget.dart';

/// Feature: Insights - Main Page
///
/// Future relationship insights, AI-powered recommendations,
/// and relationship health metrics.
class InsightsPage extends StatefulWidget {
  final String? currentUserId;
  final InsightsController? controller;

  const InsightsPage({
    super.key,
    this.currentUserId,
    this.controller,
  });

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  late final InsightsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? InsightsController();
    if (widget.currentUserId != null) {
      _controller.init(widget.currentUserId!);
    }
  }

  @override
  void didUpdateWidget(covariant InsightsPage oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Relationship Insights', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Refresh Insights',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _controller.refresh(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.healthSummary == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = _controller.healthSummary;
          final insights = _controller.insights;

          return RefreshIndicator(
            onRefresh: () => _controller.refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Health Score Card
                if (summary != null) HealthScoreCard(summary: summary),

                const SizedBox(height: 16),

                // Category Balance Breakdown
                if (summary?.categoryDistribution.isNotEmpty == true) ...[
                  CategoryBalanceCard(distribution: summary!.categoryDistribution),
                  const SizedBox(height: 20),
                ],

                // AI Recommendations Section Header
                const Text(
                  'AI Recommendations & Cadence Alerts',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),

                if (insights.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 48, color: Colors.amber.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'Your Relationships Are in Harmony!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You are on track with your relationship cadences. Keep up the great connection habits!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                else
                  ...insights.map(
                    (item) => InsightRecommendationCard(
                      insight: item,
                      onAction: () {
                        // Navigate to relationships or followups based on insight
                        Navigator.pushNamed(context, '/relationships');
                      },
                      onDismiss: () => _controller.dismiss(item.id),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
