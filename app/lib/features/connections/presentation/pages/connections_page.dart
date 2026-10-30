import 'package:flutter/material.dart';
import '../widgets/connections_widget.dart';

/// Connections feature — Friend requests, connections, and blocking.
class ConnectionsPage extends StatelessWidget {
  const ConnectionsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connections')),
      body: const ConnectionsWidget(),
    );
  }
}
