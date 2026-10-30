import 'package:flutter/material.dart';
import 'route_paths.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.home:
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Bondly Navigation')),
          ),
        );
    }
  }
}
