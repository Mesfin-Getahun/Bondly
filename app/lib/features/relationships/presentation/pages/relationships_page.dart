import 'package:flutter/material.dart';
import '../widgets/relationships_widget.dart';

/// Feature: Relationships - Page
/// Private contacts, notes, and interaction history.
/// CRITICAL PRIVACY REQUIREMENT:
/// All data in this module is strictly confidential and visible ONLY to the owner.
/// Connecting with another user must NEVER grant access to these records.
class RelationshipsPage extends StatelessWidget {
  const RelationshipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relationships')),
      body: const Center(child: RelationshipsWidget()),
    );
  }
}
