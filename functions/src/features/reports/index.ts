import * as functions from 'firebase-functions';
import { COLLECTIONS } from '../../shared/constants';

/**
 * Feature: Reports
 * Flags safety report documents for moderation review when submitted.
 */
export const onSafetyReportCreated = functions.firestore
  .document(`${COLLECTIONS.REPORTS}/{reportId}`)
  .onCreate(async (snap) => {
    await snap.ref.update({
      status: 'pending',
      flaggedAt: new Date(),
      reviewed: false,
    });
  });
