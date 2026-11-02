import * as functions from 'firebase-functions';
import { db } from '../../shared/config';
import { COLLECTIONS } from '../../shared/constants';

/**
 * Feature: Insights
 * Calculates aggregate harmony, health distribution, and cadence statistics for the user.
 */
export const calculateRelationshipInsights = functions.https.onCall(
  async (_, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated.'
      );
    }
    const userId = context.auth.uid;
    const rels = await db
      .collection(COLLECTIONS.USERS)
      .doc(userId)
      .collection(COLLECTIONS.RELATIONSHIPS)
      .get();

    const totalRels = rels.size;
    let healthyCount = 0;
    const distribution: Record<string, number> = {};

    for (const doc of rels.docs) {
      const d = doc.data();
      const cat = d.category || 'Friend';
      distribution[cat] = (distribution[cat] || 0) + 1;
      if (d.healthScore && d.healthScore >= 70) {
        healthyCount++;
      }
    }

    const overallHealth =
      totalRels > 0 ? Math.round((healthyCount / totalRels) * 100) : 100;

    return {
      overallHealth,
      totalRelationships: totalRels,
      categoryDistribution: distribution,
      calculatedAt: new Date().toISOString(),
    };
  }
);
