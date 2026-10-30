import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_INTERCEPTOR } from '@nestjs/core';

// Firebase (Global)
import { FirebaseModule } from './firebase/firebase.module';

// Common
import { ResponseInterceptor } from './common/interceptors/response.interceptor';

// Feature Modules
import { AuthModule } from './features/auth/auth.module';
import { UsersModule } from './features/users/users.module';
import { ConnectionsModule } from './features/connections/connections.module';
import { InvitationsModule } from './features/invitations/invitations.module';
import { MessagingModule } from './features/messaging/messaging.module';
import { RelationshipsModule } from './features/relationships/relationships.module';
import { FollowupsModule } from './features/followups/followups.module';
import { NotificationsModule } from './features/notifications/notifications.module';
import { GroupsModule } from './features/groups/groups.module';
import { GoalsModule } from './features/goals/goals.module';
import { ProjectsModule } from './features/projects/projects.module';
import { ReportsModule } from './features/reports/reports.module';
import { PrivacyModule } from './features/privacy/privacy.module';
import { InsightsModule } from './features/insights/insights.module';

@Module({
  imports: [
    // Load .env variables globally
    ConfigModule.forRoot({ isGlobal: true }),

    // Firebase Admin SDK — global, injected everywhere
    FirebaseModule,

    // Feature modules
    AuthModule,
    UsersModule,
    ConnectionsModule,
    InvitationsModule,
    MessagingModule,
    RelationshipsModule,
    FollowupsModule,
    NotificationsModule,
    GroupsModule,
    GoalsModule,
    ProjectsModule,
    ReportsModule,
    PrivacyModule,
    InsightsModule,
  ],
  providers: [
    // Apply ResponseInterceptor globally to all routes
    {
      provide: APP_INTERCEPTOR,
      useClass: ResponseInterceptor,
    },
  ],
})
export class AppModule {}
