import 'package:flutter/material.dart';
import '../widgets/followups_widget.dart';

/// Feature: Followups - Page
/// Follow-up schedules and reminders.
/// CRITICAL PRIVACY REQUIREMENT:
/// All data in this module is strictly confidential and visible ONLY to the owner.
/// Connecting with another user must NEVER grant access to these records.
class FollowupsPage extends StatelessWidget {
  const FollowupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Followups')),
      body: const Center(child: FollowupsWidget()),
    );
  }
}
