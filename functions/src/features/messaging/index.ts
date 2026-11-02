import * as functions from 'firebase-functions';
import { db } from '../../shared/config';
import { COLLECTIONS } from '../../shared/constants';

/**
 * Feature: Messaging
 * Dispatches conversation metadata updates and in-app notification to the message recipient.
 */
export const onMessageCreated = functions.firestore
  .document(`${COLLECTIONS.CONVERSATIONS}/{convId}/${COLLECTIONS.MESSAGES}/{msgId}`)
  .onCreate(async (snap, context) => {
    const { convId } = context.params;
    const msg = snap.data();
    const convRef = db.collection(COLLECTIONS.CONVERSATIONS).doc(convId);
    const convSnap = await convRef.get();
    if (!convSnap.exists) return;

    const convData = convSnap.data() || {};
    const participants: string[] = convData.participantIds || [];
    const recipientId = participants.find((id: string) => id !== msg.senderId);

    const now = new Date();
    const unreadMap = convData.unreadCounts || {};
    if (recipientId) {
      unreadMap[recipientId] = (unreadMap[recipientId] || 0) + 1;
    }

    await convRef.update({
      lastMessage: msg.text || 'Sent an attachment',
      lastMessageTimestamp: now,
      lastSenderId: msg.senderId,
      unreadCounts: unreadMap,
      updatedAt: now,
    });

    if (recipientId) {
      const notifRef = db.collection(COLLECTIONS.NOTIFICATIONS).doc();

      const previewText =
        msg.text && msg.text.length > 60
          ? `${msg.text.substring(0, 57)}...`
          : msg.text || 'Sent a message';

      await notifRef.set({
        id: notifRef.id,
        recipientId: recipientId,
        title: `Message from ${msg.senderName || 'A friend'}`,
        body: previewText,
        type: 'message',
        isRead: false,
        createdAt: now,
        data: {
          conversationId: convId,
          senderId: msg.senderId,
          route: '/messaging',
        },
      });
    }
  });
