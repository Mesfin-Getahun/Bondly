import * as functions from 'firebase-functions';
import { COLLECTIONS } from '../../shared/constants';

/**
 * Feature: Users
 * Keeps profile timestamp synchronized.
 */
export const onUserUpdated = functions.firestore
  .document(`${COLLECTIONS.USERS}/{userId}`)
  .onUpdate(async (change) => {
    const after = change.after.data();
    if (!after.updatedAt) {
      await change.after.ref.update({ updatedAt: new Date() });
    }
  });
