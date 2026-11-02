import * as functions from 'firebase-functions';
import { messaging, db } from '../../shared/config';
import { COLLECTIONS } from '../../shared/constants';

/**
 * Feature: Notifications
 * Dispatches FCM push notifications when a new notification document is created for a user.
 */
export const dispatchPushNotification = functions.firestore
  .document(`${COLLECTIONS.USERS}/{userId}/${COLLECTIONS.NOTIFICATIONS}/{notifId}`)
  .onCreate(async (snap, context) => {
    const { userId } = context.params;
    const notif = snap.data();

    const userDoc = await db.collection(COLLECTIONS.USERS).doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken) return;

    try {
      await messaging.send({
        token: fcmToken,
        notification: {
          title: notif.title || 'Bondly',
          body: notif.body || '',
        },
        data: {
          route: notif.data?.route || '/dashboard',
          notifId: snap.id,
        },
      });
    } catch {
      // Ignored if device token is stale or unregistered
    }
  });
