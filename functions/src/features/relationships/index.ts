import * as functions from 'firebase-functions';
import { db } from '../../shared/config';
import { COLLECTIONS } from '../../shared/constants';

/**
 * Feature: Relationships
 *
 * CRITICAL PRIVACY REQUIREMENT:
 * Relationship contacts, notes, and private interaction logs are strictly
 * isolated under `/users/{userId}/relationships/{relId}` and visible only to the owner.
 *
 * When an interaction is logged, update lastContactDate and recalculate health score.
 */
export const onInteractionCreated = functions.firestore
  .document(
    `${COLLECTIONS.USERS}/{userId}/${COLLECTIONS.RELATIONSHIPS}/{relId}/${COLLECTIONS.INTERACTIONS}/{intId}`
  )
  .onCreate(async (snap, context) => {
    const { userId, relId } = context.params;
    const interactionData = snap.data();
    const date = interactionData.date?.toDate?.() || new Date();

    const relRef = db
      .collection(COLLECTIONS.USERS)
      .doc(userId)
      .collection(COLLECTIONS.RELATIONSHIPS)
      .doc(relId);

    const relDoc = await relRef.get();
    if (!relDoc.exists) return;

    const currentHealth = relDoc.data()?.healthScore || 50;
    // Boost health score when interactions are actively logged
    const newHealthScore = Math.min(100, currentHealth + 10);

    await relRef.update({
      lastContactDate: date,
      lastInteractionSummary:
        interactionData.notes || interactionData.type || 'Logged check-in',
      healthScore: newHealthScore,
      updatedAt: new Date(),
    });
  });
