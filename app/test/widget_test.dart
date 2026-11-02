import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/auth/presentation/pages/auth_page.dart';
import 'package:frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:frontend/features/auth/domain/usecases/get_auth_usecase.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/entities/auth_entity.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Stream<AuthEntity?> get authStateChanges => Stream.value(null);

  @override
  AuthEntity? get currentUser => null;

  @override
  Future<AuthEntity> signInAnonymously() async {
    return const AuthEntity(
      id: 'mock_guest',
      displayName: 'Guest Explorer',
      email: 'guest@bondly.app',
      isAnonymous: true,
    );
  }

  @override
  Future<AuthEntity> signInWithEmail(String email, String password) async {
    return const AuthEntity(
      id: 'mock_user',
      displayName: 'Mock User',
      email: 'test@example.com',
      isAnonymous: false,
    );
  }

  @override
  Future<AuthEntity> signUpWithEmail(String email, String password, {String? displayName}) async {
    return const AuthEntity(
      id: 'mock_new_user',
      displayName: displayName ?? 'New User',
      email: email,
      isAnonymous: false,
    );
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordReset(String email) async {}
}

void main() {
  testWidgets('AuthPage renders title, forms, and Guest Preview button',
      (WidgetTester tester) async {
    final mockRepo = MockAuthRepository();
    final controller = AuthController(useCases: AuthUseCases(mockRepo));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: AuthPage(controller: controller),
      ),
    );

    // Verify Brand title
    expect(find.text('Bondly'), findsOneWidget);
    expect(
      find.text('Meaningful connections & private relationship tracking'),
      findsOneWidget,
    );

    // Verify Guest Button
    expect(find.text('Continue as Guest (Instant Preview)'), findsOneWidget);

    // Verify Email & Password input fields exist
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
