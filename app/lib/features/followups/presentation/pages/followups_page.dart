import 'package:flutter/material.dart';
import '../widgets/followups_widget.dart';

/// Followups feature — Follow-up schedules and reminders.
class FollowupsPage extends StatelessWidget {
  const FollowupsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Follow-ups')),
      body: const FollowupsWidget(),
    );
  }
}
