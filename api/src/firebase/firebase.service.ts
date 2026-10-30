import { Injectable, OnApplicationBootstrap } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { readFileSync, existsSync } from 'fs';
import { resolve } from 'path';

/**
 * FirebaseService — globally available wrapper around Firebase Admin SDK.
 *
 * Provides typed accessors for:
 *   - firestore  → Cloud Firestore instance
 *   - auth       → Firebase Authentication instance
 *   - storage    → Firebase Storage instance
 *   - messaging  → Firebase Cloud Messaging instance
 */
@Injectable()
export class FirebaseService implements OnApplicationBootstrap {
  private _app: admin.app.App;

  onApplicationBootstrap() {
    if (admin.apps.length > 0) {
      this._app = admin.apps[0]!;
      return;
    }

    const serviceAccountPath = resolve(
      process.env.FIREBASE_SERVICE_ACCOUNT_PATH ?? './firebase-service-account.json',
    );

    if (existsSync(serviceAccountPath)) {
      // Initialize with explicit service account JSON (recommended for local dev)
      const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf-8'));
      this._app = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      console.log('✅ Firebase initialized with service account key');
    } else {
      // Fallback: Application Default Credentials (ADC) — for CI / Cloud Run
      this._app = admin.initializeApp({
        credential: admin.credential.applicationDefault(),
        projectId: process.env.FIREBASE_PROJECT_ID,
      });
      console.log('✅ Firebase initialized with Application Default Credentials');
    }
  }

  get app(): admin.app.App {
    return this._app;
  }

  get firestore(): admin.firestore.Firestore {
    return this._app.firestore();
  }

  get auth(): admin.auth.Auth {
    return this._app.auth();
  }

  get storage(): admin.storage.Storage {
    return this._app.storage();
  }

  get messaging(): admin.messaging.Messaging {
    return this._app.messaging();
  }
}
