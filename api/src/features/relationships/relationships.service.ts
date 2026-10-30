import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import { FieldValue } from 'firebase-admin/firestore';

/** STRICT PRIVACY — subcollection /users/{uid}/relationships is owner-only */
@Injectable()
export class RelationshipsService {
  private col(uid: string) {
    return this.firebase.firestore.collection('users').doc(uid).collection('relationships');
  }
  constructor(private readonly firebase: FirebaseService) {}

  async findAll(uid: string) {
    const snap = await this.col(uid).get();
    return snap.docs.map(d => ({ id: d.id, ...d.data() }));
  }

  async create(uid: string, data: Record<string, unknown>) {
    const ref = this.col(uid).doc();
    const payload = { ...data, createdAt: FieldValue.serverTimestamp() };
    await ref.set(payload);
    return { id: ref.id, ...payload };
  }

  async findOne(uid: string, id: string) {
    const doc = await this.col(uid).doc(id).get();
    return doc.exists ? { id: doc.id, ...doc.data() } : null;
  }

  async update(uid: string, id: string, data: Record<string, unknown>) {
    await this.col(uid).doc(id).set({ ...data, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    return this.findOne(uid, id);
  }

  async remove(uid: string, id: string) {
    await this.col(uid).doc(id).delete();
    return { deleted: true };
  }
}
