import 'package:flutter/material.dart';
import '../widgets/messaging_widget.dart';

/// Feature: Messaging - Page
/// Direct messages and conversations.
class MessagingPage extends StatelessWidget {
  const MessagingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messaging')),
      body: const Center(child: MessagingWidget()),
    );
  }
}
