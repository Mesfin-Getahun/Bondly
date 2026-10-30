import 'package:flutter/material.dart';
import '../widgets/privacy_widget.dart';

/// Feature: Privacy - Page
/// Privacy settings, data export, consent, and account deletion.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: const Center(child: PrivacyWidget()),
    );
  }
}
