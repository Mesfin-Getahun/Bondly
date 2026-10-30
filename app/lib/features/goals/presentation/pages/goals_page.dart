import 'package:flutter/material.dart';
import '../widgets/goals_widget.dart';

/// Goals feature — Personal and shared goals.
class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: const GoalsWidget(),
    );
  }
}
