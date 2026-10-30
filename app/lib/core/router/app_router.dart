import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'route_paths.dart';

// Feature pages
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../../features/connections/presentation/pages/connections_page.dart';
import '../../features/invitations/presentation/pages/invitations_page.dart';
import '../../features/messaging/presentation/pages/messaging_page.dart';
import '../../features/relationships/presentation/pages/relationships_page.dart';
import '../../features/followups/presentation/pages/followups_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/groups/presentation/pages/groups_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/projects/presentation/pages/projects_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/privacy/presentation/pages/privacy_page.dart';
import '../../features/insights/presentation/pages/insights_page.dart';

/// Global GoRouter provider.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.auth,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RoutePaths.auth,
        name: 'auth',
        builder: (ctx, state) => const AuthPage(),
      ),
      GoRoute(
        path: RoutePaths.users,
        name: 'users',
        builder: (ctx, state) => const UsersPage(),
      ),
      GoRoute(
        path: RoutePaths.connections,
        name: 'connections',
        builder: (ctx, state) => const ConnectionsPage(),
      ),
      GoRoute(
        path: RoutePaths.invitations,
        name: 'invitations',
        builder: (ctx, state) => const InvitationsPage(),
      ),
      GoRoute(
        path: RoutePaths.messaging,
        name: 'messaging',
        builder: (ctx, state) => const MessagingPage(),
      ),
      GoRoute(
        path: RoutePaths.relationships,
        name: 'relationships',
        builder: (ctx, state) => const RelationshipsPage(),
      ),
      GoRoute(
        path: RoutePaths.followups,
        name: 'followups',
        builder: (ctx, state) => const FollowupsPage(),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        name: 'notifications',
        builder: (ctx, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: RoutePaths.groups,
        name: 'groups',
        builder: (ctx, state) => const GroupsPage(),
      ),
      GoRoute(
        path: RoutePaths.goals,
        name: 'goals',
        builder: (ctx, state) => const GoalsPage(),
      ),
      GoRoute(
        path: RoutePaths.projects,
        name: 'projects',
        builder: (ctx, state) => const ProjectsPage(),
      ),
      GoRoute(
        path: RoutePaths.reports,
        name: 'reports',
        builder: (ctx, state) => const ReportsPage(),
      ),
      GoRoute(
        path: RoutePaths.privacy,
        name: 'privacy',
        builder: (ctx, state) => const PrivacyPage(),
      ),
      GoRoute(
        path: RoutePaths.insights,
        name: 'insights',
        builder: (ctx, state) => const InsightsPage(),
      ),
    ],
  );
});
