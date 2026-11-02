import * as functions from 'firebase-functions';
import { db } from '../../shared/config';
import { COLLECTIONS } from '../../shared/constants';

/**
 * Feature: Auth
 * Automatically initializes user record in Firestore when account is created.
 */
export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  const userRef = db.collection(COLLECTIONS.USERS).doc(user.uid);
  const now = new Date();
  await userRef.set(
    {
      id: user.uid,
      email: user.email || '',
      displayName: user.displayName || 'Bondly Member',
      photoUrl: user.photoURL || null,
      createdAt: now,
      updatedAt: now,
      preferredCadence: 'biweekly',
      theme: 'dark',
      allowDiscovery: false,
      analyticsEnabled: false,
    },
    { merge: true }
  );
});

/**
 * Feature: Auth
 * Cleans up user private data when account is permanently deleted.
 */
export const onUserDeleted = functions.auth.user().onDelete(async (user) => {
  const userRef = db.collection(COLLECTIONS.USERS).doc(user.uid);
  await db.recursiveDelete(userRef);
});
