import 'package:flutter/material.dart';
import '../widgets/insights_widget.dart';

/// Feature: Insights - Page
/// Relationship insights and AI-powered recommendations.
class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: const Center(child: InsightsWidget()),
    );
  }
}
