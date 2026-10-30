import 'package:flutter/material.dart';
import '../widgets/invitations_widget.dart';

/// Invitations feature — Private invitation links and codes.
class InvitationsPage extends StatelessWidget {
  const InvitationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invitations')),
      body: const InvitationsWidget(),
    );
  }
}
