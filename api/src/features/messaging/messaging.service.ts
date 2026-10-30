import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import { FieldValue } from 'firebase-admin/firestore';

@Injectable()
export class MessagingService {
  private get db() { return this.firebase.firestore; }
  constructor(private readonly firebase: FirebaseService) {}

  async getConversations(uid: string) {
    const snap = await this.db.collection('conversations')
      .where('participants', 'array-contains', uid).get();
    return snap.docs.map(d => ({ id: d.id, ...d.data() }));
  }

  async createConversation(uid: string, participantUid: string) {
    const ref = this.db.collection('conversations').doc();
    const data = {
      participants: [uid, participantUid],
      createdAt: FieldValue.serverTimestamp(),
      lastMessage: null,
    };
    await ref.set(data);
    return { id: ref.id, ...data };
  }

  async getMessages(conversationId: string) {
    const snap = await this.db
      .collection('conversations').doc(conversationId)
      .collection('messages').orderBy('sentAt', 'asc').get();
    return snap.docs.map(d => ({ id: d.id, ...d.data() }));
  }

  async sendMessage(conversationId: string, senderUid: string, text: string) {
    const ref = this.db
      .collection('conversations').doc(conversationId)
      .collection('messages').doc();
    const data = { senderUid, text, sentAt: FieldValue.serverTimestamp(), read: false };
    await ref.set(data);
    // Update conversation's lastMessage
    await this.db.collection('conversations').doc(conversationId).update({
      lastMessage: { text, senderUid, sentAt: FieldValue.serverTimestamp() },
    });
    return { id: ref.id, ...data };
  }
}
