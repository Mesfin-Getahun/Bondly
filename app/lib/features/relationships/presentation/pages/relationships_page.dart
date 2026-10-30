import 'package:flutter/material.dart';
import '../widgets/relationships_widget.dart';

/// Relationships feature — Private contacts, notes, and interaction history.
class RelationshipsPage extends StatelessWidget {
  const RelationshipsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relationships')),
      body: const RelationshipsWidget(),
    );
  }
}
