import * as functions from 'firebase-functions';
import { db } from '../../shared/config';
import { COLLECTIONS } from '../../shared/constants';

/**
 * Feature: Groups
 * Updates circle member count when a new member is added.
 */
export const onGroupMemberAdded = functions.firestore
  .document(`${COLLECTIONS.GROUPS}/{groupId}/members/{memberId}`)
  .onCreate(async (snap, context) => {
    const { groupId, memberId } = context.params;
    const groupRef = db.collection(COLLECTIONS.GROUPS).doc(groupId);
    const membersSnap = await groupRef.collection('members').get();

    await groupRef.update({
      memberCount: membersSnap.size,
      updatedAt: new Date(),
    });

    const notifRef = db.collection(COLLECTIONS.NOTIFICATIONS).doc();

    await notifRef.set({
      id: notifRef.id,
      recipientId: memberId,
      title: 'Added to Circle',
      body: 'You have been added to a shared circle.',
      type: 'group',
      isRead: false,
      createdAt: new Date(),
      data: { groupId, route: '/groups' },
    });
  });
