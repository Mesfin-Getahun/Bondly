import * as functions from 'firebase-functions';
import { db } from '../../shared/config';
import { COLLECTIONS } from '../../shared/constants';

/**
 * Feature: Goals
 * Dispatches celebration notification when a goal is completed.
 */
export const onGoalCompleted = functions.firestore
  .document(`${COLLECTIONS.GOALS}/{goalId}`)
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    if (!before.isCompleted && after.isCompleted && after.ownerId) {
      const notifRef = db
        .collection(COLLECTIONS.USERS)
        .doc(after.ownerId)
        .collection(COLLECTIONS.NOTIFICATIONS)
        .doc();

      await notifRef.set({
        id: notifRef.id,
        title: 'Goal Achieved! 🎯',
        body: `Congratulations! You marked "${after.title}" as complete.`,
        type: 'goal_completed',
        isRead: false,
        createdAt: new Date(),
        data: { goalId: change.after.id, route: '/goals' },
      });
    }
  });
