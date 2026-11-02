import * as functions from 'firebase-functions';
import { db } from '../../shared/config';
import { COLLECTIONS } from '../../shared/constants';

/**
 * Feature: Followups
 *
 * CRITICAL PRIVACY REQUIREMENT:
 * Follow-up schedules and reminders are private to the user.
 *
 * Daily scheduled function checking for due or overdue follow-up check-ins.
 */
export const checkFollowupReminders = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async () => {
    const now = new Date();

    const pendingFollowups = await db
      .collectionGroup(COLLECTIONS.FOLLOWUPS)
      .where('isCompleted', '==', false)
      .where('dueDate', '<=', now)
      .limit(500)
      .get();

    const batch = db.batch();

    for (const doc of pendingFollowups.docs) {
      const data = doc.data();
      const parentUserDoc = doc.ref.parent.parent;
      if (!parentUserDoc) continue;
      const userId = parentUserDoc.id;

      const notifRef = db
        .collection(COLLECTIONS.USERS)
        .doc(userId)
        .collection(COLLECTIONS.NOTIFICATIONS)
        .doc();

      batch.set(notifRef, {
        id: notifRef.id,
        title: `Reminder: Check in with ${data.contactName || 'your friend'}`,
        body: data.title || 'You have a scheduled relationship follow-up.',
        type: 'followup',
        isRead: false,
        createdAt: now,
        data: {
          followupId: doc.id,
          contactName: data.contactName,
          route: '/followups',
        },
      });

      batch.update(doc.ref, { reminderDispatched: true });
    }

    await batch.commit();
  });
