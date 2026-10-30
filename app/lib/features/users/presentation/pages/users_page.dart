import 'package:flutter/material.dart';
import '../widgets/users_widget.dart';

/// Users feature — User profiles and account settings.
class UsersPage extends StatelessWidget {
  const UsersPage({super.key});
  @override
  Widget build(BuildContext context) => _FeaturePlaceholder(
        featureName: 'Users',
        icon: Icons.person_outline,
        description: 'User profiles and account settings.',
        child: const UsersWidget(),
      );
}

class _FeaturePlaceholder extends StatelessWidget {
  final String featureName;
  final IconData icon;
  final String description;
  final Widget child;
  const _FeaturePlaceholder({
    required this.featureName,
    required this.icon,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(featureName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(featureName, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
