import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/main_navigation_shell.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/pages/auth_page.dart';

/// Root application widget for Bondly with Auth Session gate.
class BondlyApp extends StatefulWidget {
  const BondlyApp({super.key});

  @override
  State<BondlyApp> createState() => _BondlyAppState();
}

class _BondlyAppState extends State<BondlyApp> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: ListenableBuilder(
        listenable: _authController,
        builder: (context, _) {
          if (_authController.isAuthenticated) {
            return MainNavigationShell(authController: _authController);
          } else {
            return AuthPage(controller: _authController);
          }
        },
      ),
    );
  }
}
