import 'package:flutter/material.dart';
import '../widgets/groups_widget.dart';

/// Feature: Groups - Page
/// Groups, memberships, and permissions.
class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: const Center(child: GroupsWidget()),
    );
  }
}
