import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import { FieldValue } from 'firebase-admin/firestore';

/** STRICT PRIVACY — subcollection /users/{uid}/followups is owner-only */
@Injectable()
export class FollowupsService {
  private col(uid: string) {
    return this.firebase.firestore.collection('users').doc(uid).collection('followups');
  }
  constructor(private readonly firebase: FirebaseService) {}

  async findAll(uid: string) {
    const snap = await this.col(uid).orderBy('scheduledAt', 'asc').get();
    return snap.docs.map(d => ({ id: d.id, ...d.data() }));
  }

  async create(uid: string, data: Record<string, unknown>) {
    const ref = this.col(uid).doc();
    const payload = { ...data, createdAt: FieldValue.serverTimestamp() };
    await ref.set(payload);
    return { id: ref.id, ...payload };
  }

  async update(uid: string, id: string, data: Record<string, unknown>) {
    await this.col(uid).doc(id).set({ ...data, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    const doc = await this.col(uid).doc(id).get();
    return { id: doc.id, ...doc.data() };
  }

  async remove(uid: string, id: string) {
    await this.col(uid).doc(id).delete();
    return { deleted: true };
  }
}
