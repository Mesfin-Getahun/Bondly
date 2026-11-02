import * as functions from 'firebase-functions';
import { db } from '../../shared/config';
import { COLLECTIONS } from '../../shared/constants';

/**
 * Feature: Invitations
 * Notifies the invitation creator when someone successfully redeems their invitation code.
 */
export const onInvitationUpdated = functions.firestore
  .document(`${COLLECTIONS.INVITATIONS}/{invId}`)
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status !== 'accepted' && after.status === 'accepted') {
      const notifRef = db.collection(COLLECTIONS.NOTIFICATIONS).doc();

      await notifRef.set({
        id: notifRef.id,
        recipientId: after.senderId,
        title: 'Invite Code Redeemed! 🎉',
        body: `${after.claimedByName || 'A friend'} used your invite code (${after.code}) to connect.`,
        type: 'invitation_redeemed',
        isRead: false,
        createdAt: new Date(),
        data: {
          invitationId: change.after.id,
          claimedById: after.claimedBy,
          route: '/invitations',
        },
      });
    }
  });
