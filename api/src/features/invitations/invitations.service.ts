import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import { FieldValue } from 'firebase-admin/firestore';
import { randomBytes } from 'crypto';

@Injectable()
export class InvitationsService {
  private get db() { return this.firebase.firestore; }
  constructor(private readonly firebase: FirebaseService) {}

  async findByUser(uid: string) {
    const snap = await this.db.collection('invitations').where('senderId', '==', uid).get();
    return snap.docs.map(d => ({ id: d.id, ...d.data() }));
  }

  async create(uid: string, data: Record<string, unknown>) {
    const code = randomBytes(6).toString('hex');
    const ref = this.db.collection('invitations').doc();
    const payload = { ...data, senderId: uid, code, createdAt: FieldValue.serverTimestamp() };
    await ref.set(payload);
    return { id: ref.id, ...payload };
  }

  async resolveCode(code: string) {
    const snap = await this.db.collection('invitations').where('code', '==', code).limit(1).get();
    if (snap.empty) return null;
    const doc = snap.docs[0];
    return { id: doc.id, ...doc.data() };
  }

  async revoke(id: string, uid: string) {
    await this.db.collection('invitations').doc(id).delete();
    return { revoked: true };
  }
}
