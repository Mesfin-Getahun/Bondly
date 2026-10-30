import 'package:flutter/material.dart';
import '../widgets/users_widget.dart';

/// Feature: Users - Page
/// User profiles and account settings.
class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: const Center(child: UsersWidget()),
    );
  }
}
