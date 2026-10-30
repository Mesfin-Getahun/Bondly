import 'package:flutter/material.dart';
import '../widgets/groups_widget.dart';

/// Groups feature — Groups, memberships, and permissions.
class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: const GroupsWidget(),
    );
  }
}
