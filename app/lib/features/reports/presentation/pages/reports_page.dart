import 'package:flutter/material.dart';
import '../widgets/reports_widget.dart';

/// Reports feature — User reports and moderation.
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: const ReportsWidget(),
    );
  }
}
