import 'package:flutter/material.dart';
import '../widgets/auth_widget.dart';

/// Feature: Auth - Page
/// Registration, login, authentication, and sessions.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: const Center(child: AuthWidget()),
    );
  }
}
