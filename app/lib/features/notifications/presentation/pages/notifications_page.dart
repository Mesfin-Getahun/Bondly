import 'package:flutter/material.dart';
import '../widgets/notifications_widget.dart';

/// Feature: Notifications - Page
/// Push notification handling.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: NotificationsWidget()),
    );
  }
}
