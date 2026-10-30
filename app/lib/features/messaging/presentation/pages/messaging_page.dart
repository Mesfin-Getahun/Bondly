import 'package:flutter/material.dart';
import '../widgets/messaging_widget.dart';

/// Messaging feature — Direct messages and conversations.
class MessagingPage extends StatelessWidget {
  const MessagingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const MessagingWidget(),
    );
  }
}
