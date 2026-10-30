import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';

@Injectable()
export class InsightsService {
  constructor(private readonly firebase: FirebaseService) {}

  async findForUser(uid: string) {
    const snap = await this.firebase.firestore
      .collection('users').doc(uid)
      .collection('insights')
      .orderBy('generatedAt', 'desc')
      .limit(20)
      .get();
    return snap.docs.map(d => ({ id: d.id, ...d.data() }));
  }
}
