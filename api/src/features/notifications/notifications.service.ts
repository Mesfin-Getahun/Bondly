import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';

@Injectable()
export class NotificationsService {
  private get db() { return this.firebase.firestore; }
  constructor(private readonly firebase: FirebaseService) {}

  async findForUser(uid: string) {
    const snap = await this.db.collection('notifications')
      .where('recipientId', '==', uid)
      .orderBy('createdAt', 'desc')
      .limit(50)
      .get();
    return snap.docs.map(d => ({ id: d.id, ...d.data() }));
  }

  async send(recipientId: string, payload: { title: string; body: string; data?: Record<string, string> }) {
    // Store in Firestore
    await this.db.collection('notifications').add({
      recipientId,
      ...payload,
      read: false,
      createdAt: new Date(),
    });
    // Send via FCM if needed
    try {
      const userDoc = await this.db.collection('users').doc(recipientId).get();
      const fcmToken = userDoc.data()?.fcmToken;
      if (fcmToken) {
        await this.firebase.messaging.send({
          token: fcmToken,
          notification: { title: payload.title, body: payload.body },
          data: payload.data,
        });
      }
    } catch { /* FCM failures are non-critical */ }
  }
}
