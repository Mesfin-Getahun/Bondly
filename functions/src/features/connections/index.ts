import * as functions from 'firebase-functions';
import { db } from '../../shared/config';
import { COLLECTIONS } from '../../shared/constants';

/**
 * Feature: Connections
 * Notifies recipient when a connection request is sent.
 */
export const onConnectionCreated = functions.firestore
  .document(`${COLLECTIONS.CONNECTIONS}/{connId}`)
  .onCreate(async (snap) => {
    const conn = snap.data();
    if (!conn.recipientId) return;

    const notifRef = db.collection(COLLECTIONS.NOTIFICATIONS).doc();

    await notifRef.set({
      id: notifRef.id,
      recipientId: conn.recipientId,
      title: 'New Connection Request',
      body: `${conn.senderName || 'Someone'} sent you a connection request.`,
      type: 'connection_request',
      isRead: false,
      createdAt: new Date(),
      data: {
        connectionId: snap.id,
        senderId: conn.senderId,
        route: '/connections',
      },
    });
  });

/**
 * Feature: Connections
 * Notifies original sender when their connection request is accepted.
 */
export const onConnectionUpdated = functions.firestore
  .document(`${COLLECTIONS.CONNECTIONS}/{connId}`)
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status !== 'accepted' && after.status === 'accepted') {
      const notifRef = db.collection(COLLECTIONS.NOTIFICATIONS).doc();

      await notifRef.set({
        id: notifRef.id,
        recipientId: after.senderId,
        title: 'Connection Accepted! 🎉',
        body: `${after.recipientName || 'Your friend'} accepted your connection request.`,
        type: 'connection_accepted',
        isRead: false,
        createdAt: new Date(),
        data: {
          connectionId: change.after.id,
          recipientId: after.recipientId,
          route: '/connections',
        },
      });
    }
  });
