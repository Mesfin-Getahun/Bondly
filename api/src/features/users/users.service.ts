import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';

@Injectable()
export class UsersService {
  private get db() { return this.firebase.firestore; }
  constructor(private readonly firebase: FirebaseService) {}

  async findById(uid: string) {
    const doc = await this.db.collection('users').doc(uid).get();
    return doc.exists ? { id: doc.id, ...doc.data() } : null;
  }

  async updateProfile(uid: string, data: Record<string, unknown>) {
    await this.db.collection('users').doc(uid).set(data, { merge: true });
    return this.findById(uid);
  }

  async deleteAccount(uid: string) {
    await this.firebase.auth.deleteUser(uid);
    await this.db.collection('users').doc(uid).delete();
    return { deleted: true };
  }
}
