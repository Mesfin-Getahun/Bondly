import 'package:flutter/material.dart';
import '../../features/connections/presentation/pages/connections_page.dart';
import '../../features/followups/presentation/pages/followups_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/groups/presentation/pages/groups_page.dart';
import '../../features/insights/presentation/pages/insights_page.dart';
import '../../features/invitations/presentation/pages/invitations_page.dart';
import '../../features/messaging/presentation/pages/messaging_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/privacy/presentation/pages/privacy_page.dart';
import '../../features/projects/presentation/pages/projects_page.dart';
import '../../features/relationships/presentation/pages/relationships_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import 'route_paths.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.users:
        return MaterialPageRoute(builder: (_) => const UsersPage());
      case RoutePaths.relationships:
        return MaterialPageRoute(builder: (_) => const RelationshipsPage());
      case RoutePaths.messaging:
        return MaterialPageRoute(builder: (_) => const MessagingPage());
      case RoutePaths.connections:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ConnectionsPage(
            currentUserId: args?['currentUserId'],
            currentUserName: args?['currentUserName'],
          ),
        );
      case RoutePaths.invitations:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => InvitationsPage(
            currentUserId: args?['currentUserId'],
            currentUserName: args?['currentUserName'],
          ),
        );
      case RoutePaths.followups:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => FollowupsPage(
            currentUserId: args?['currentUserId'],
          ),
        );
      case RoutePaths.notifications:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => NotificationsPage(
            currentUserId: args?['currentUserId'],
          ),
        );
      case RoutePaths.groups:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => GroupsPage(
            currentUserId: args?['currentUserId'],
            currentUserName: args?['currentUserName'],
          ),
        );
      case RoutePaths.goals:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => GoalsPage(
            currentUserId: args?['currentUserId'],
            currentUserName: args?['currentUserName'],
          ),
        );
      case RoutePaths.projects:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProjectsPage(
            currentUserId: args?['currentUserId'],
            currentUserName: args?['currentUserName'],
          ),
        );
      case RoutePaths.reports:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ReportsPage(
            currentUserId: args?['currentUserId'],
            currentUserName: args?['currentUserName'],
          ),
        );
      case RoutePaths.privacy:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PrivacyPage(
            currentUserId: args?['currentUserId'],
          ),
        );
      case RoutePaths.insights:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => InsightsPage(
            currentUserId: args?['currentUserId'],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
