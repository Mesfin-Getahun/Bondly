import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import { FieldValue } from 'firebase-admin/firestore';

@Injectable()
export class GoalsService {
  private get db() { return this.firebase.firestore; }
  private col = 'goals';
  constructor(private readonly firebase: FirebaseService) {}

  async findAll(uid: string) {
    const snap = await this.db.collection(this.col).where('ownerId', '==', uid).get();
    return snap.docs.map(d => ({ id: d.id, ...d.data() }));
  }
  async create(uid: string, data: Record<string, unknown>) {
    const ref = this.db.collection(this.col).doc();
    const payload = { ...data, ownerId: uid, createdAt: FieldValue.serverTimestamp() };
    await ref.set(payload);
    return { id: ref.id, ...payload };
  }
  async update(id: string, data: Record<string, unknown>) {
    await this.db.collection(this.col).doc(id).set({ ...data, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    const d = await this.db.collection(this.col).doc(id).get();
    return { id: d.id, ...d.data() };
  }
  async remove(id: string) {
    await this.db.collection(this.col).doc(id).delete();
    return { deleted: true };
  }
}
