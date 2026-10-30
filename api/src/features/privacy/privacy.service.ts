import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import { FieldValue } from 'firebase-admin/firestore';

@Injectable()
export class PrivacyService {
  private col(uid: string) {
    return this.firebase.firestore.collection('users').doc(uid).collection('privacy');
  }
  constructor(private readonly firebase: FirebaseService) {}

  async getSettings(uid: string) {
    const doc = await this.col(uid).doc('settings').get();
    return doc.exists ? doc.data() : {};
  }

  async updateSettings(uid: string, data: Record<string, unknown>) {
    await this.col(uid).doc('settings').set({ ...data, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    return this.getSettings(uid);
  }

  async requestDataExport(uid: string) {
    await this.col(uid).doc('exportRequest').set({ requestedAt: FieldValue.serverTimestamp(), status: 'pending' });
    return { message: 'Data export request submitted. You will be notified when ready.' };
  }

  async requestAccountDeletion(uid: string) {
    await this.col(uid).doc('deletionRequest').set({ requestedAt: FieldValue.serverTimestamp(), status: 'pending' });
    return { message: 'Account deletion request submitted. Account will be removed within 30 days.' };
  }
}
