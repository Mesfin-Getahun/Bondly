import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../../firebase/firebase.service';
import { FieldValue } from 'firebase-admin/firestore';

@Injectable()
export class ReportsService {
  private get db() { return this.firebase.firestore; }
  constructor(private readonly firebase: FirebaseService) {}

  async create(reporterUid: string, data: Record<string, unknown>) {
    const ref = this.db.collection('reports').doc();
    const payload = { ...data, reporterUid, status: 'pending', createdAt: FieldValue.serverTimestamp() };
    await ref.set(payload);
    return { id: ref.id };
  }
}
