import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import { FieldValue } from 'firebase-admin/firestore';

@Injectable()
export class ProjectsService {
  private get db() { return this.firebase.firestore; }
  private col = 'projects';
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
  async findOne(id: string) {
    const d = await this.db.collection(this.col).doc(id).get();
    return d.exists ? { id: d.id, ...d.data() } : null;
  }
  async update(id: string, data: Record<string, unknown>) {
    await this.db.collection(this.col).doc(id).set({ ...data, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    return this.findOne(id);
  }
  async remove(id: string) {
    await this.db.collection(this.col).doc(id).delete();
    return { deleted: true };
  }
}
