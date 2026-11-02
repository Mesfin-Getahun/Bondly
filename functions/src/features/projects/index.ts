import * as functions from 'firebase-functions';
import { db } from '../../shared/config';
import { COLLECTIONS } from '../../shared/constants';

/**
 * Feature: Projects
 * Dispatches completion alert when project milestones reach 100%.
 */
export const onProjectUpdated = functions.firestore
  .document(`${COLLECTIONS.PROJECTS}/{projectId}`)
  .onUpdate(async (change) => {
    const after = change.after.data();
    const before = change.before.data();

    if (
      after.progress === 100 &&
      before.progress !== 100 &&
      after.ownerId
    ) {
      const notifRef = db.collection(COLLECTIONS.NOTIFICATIONS).doc();

      await notifRef.set({
        id: notifRef.id,
        recipientId: after.ownerId,
        title: 'Project Completed! 🚀',
        body: `All milestones reached for "${after.title}".`,
        type: 'project_completed',
        isRead: false,
        createdAt: new Date(),
        data: { projectId: change.after.id, route: '/projects' },
      });
    }
  });
