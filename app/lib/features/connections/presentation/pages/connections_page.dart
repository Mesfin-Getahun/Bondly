import 'package:flutter/material.dart';
import '../widgets/connections_widget.dart';

/// Feature: Connections - Page
/// Friend requests, connections, and blocking.
class ConnectionsPage extends StatelessWidget {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connections')),
      body: const Center(child: ConnectionsWidget()),
    );
  }
}
