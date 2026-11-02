import * as functions from 'firebase-functions';
import { db } from '../../shared/config';
import { COLLECTIONS } from '../../shared/constants';

/**
 * Feature: Privacy
 * Allows authenticated user to export all their private data in JSON format (GDPR/Data Portability).
 */
export const exportUserData = functions.https.onCall(async (_, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to export data.'
    );
  }

  const userId = context.auth.uid;
  const userDoc = await db.collection(COLLECTIONS.USERS).doc(userId).get();
  const relationshipsSnap = await db
    .collection(COLLECTIONS.USERS)
    .doc(userId)
    .collection(COLLECTIONS.RELATIONSHIPS)
    .get();
  const followupsSnap = await db
    .collection(COLLECTIONS.USERS)
    .doc(userId)
    .collection(COLLECTIONS.FOLLOWUPS)
    .get();

  return {
    exportedAt: new Date().toISOString(),
    profile: userDoc.data() || {},
    relationships: relationshipsSnap.docs.map((d) => ({
      id: d.id,
      ...d.data(),
    })),
    followups: followupsSnap.docs.map((d) => ({
      id: d.id,
      ...d.data(),
    })),
  };
});
