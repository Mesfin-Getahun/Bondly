import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Auth feature — Login & Registration screen.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text('Welcome to Bondly', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(140),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.goNamed('users'),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
