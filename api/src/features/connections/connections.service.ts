import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import { FieldValue } from 'firebase-admin/firestore';

@Injectable()
export class ConnectionsService {
  private get db() { return this.firebase.firestore; }
  constructor(private readonly firebase: FirebaseService) {}

  async findAllForUser(uid: string) {
    const snap = await this.db.collection('connections')
      .where('userA', '==', uid).get();
    const snap2 = await this.db.collection('connections')
      .where('userB', '==', uid).get();
    return [...snap.docs, ...snap2.docs].map(d => ({ id: d.id, ...d.data() }));
  }

  async sendRequest(fromUid: string, toUid: string) {
    const ref = this.db.collection('connections').doc();
    const data = { userA: fromUid, userB: toUid, status: 'pending', createdAt: FieldValue.serverTimestamp() };
    await ref.set(data);
    return { id: ref.id, ...data };
  }

  async acceptRequest(connectionId: string, uid: string) {
    const ref = this.db.collection('connections').doc(connectionId);
    await ref.update({ status: 'connected', updatedAt: FieldValue.serverTimestamp() });
    return { id: connectionId, status: 'connected' };
  }

  async remove(connectionId: string, uid: string) {
    await this.db.collection('connections').doc(connectionId).delete();
    return { deleted: true };
  }
}
