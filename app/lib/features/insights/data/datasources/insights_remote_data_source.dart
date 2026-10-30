import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/insights_entity.dart';
import '../models/insights_model.dart';

/// Feature: Insights - Remote Data Source Interface
abstract class InsightsRemoteDataSource {
  Stream<List<InsightModel>> watchInsights(String userId);
  Future<RelationshipHealthSummary> computeHealthSummary(String userId);
  Future<void> generateSmartInsights(String userId);
  Future<void> dismissInsight(String userId, String insightId);
}

/// Implementation using Cloud Firestore
class FirestoreInsightsRemoteDataSourceImpl implements InsightsRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreInsightsRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _insightsRef(String userId) =>
      _firestore.collection(FirestoreCollections.users).doc(userId).collection(FirestoreCollections.insights);

  CollectionReference<Map<String, dynamic>> _relationshipsRef(String userId) =>
      _firestore.collection(FirestoreCollections.users).doc(userId).collection(FirestoreCollections.relationships);

  CollectionReference<Map<String, dynamic>> _followupsRef(String userId) =>
      _firestore.collection(FirestoreCollections.users).doc(userId).collection(FirestoreCollections.followups);

  @override
  Stream<List<InsightModel>> watchInsights(String userId) {
    if (userId.isEmpty) return Stream.value([]);

    return _insightsRef(userId)
        .where('isDismissed', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => InsightModel.fromFirestore(doc, userId)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<RelationshipHealthSummary> computeHealthSummary(String userId) async {
    try {
      if (userId.isEmpty) return const RelationshipHealthSummary();

      final relationshipsSnap = await _relationshipsRef(userId).get();
      final total = relationshipsSnap.docs.length;

      if (total == 0) {
        return const RelationshipHealthSummary(
          overallScore: 90,
          totalRelationships: 0,
          healthyCadenceCount: 0,
          overdueCadenceCount: 0,
          streakDays: 1,
          categoryDistribution: {},
        );
      }

      final now = DateTime.now();
      int overdue = 0;
      int healthy = 0;
      final Map<String, int> catDist = {};

      for (final doc in relationshipsSnap.docs) {
        final data = doc.data();
        final cat = data['category'] as String? ?? 'Friend';
        catDist[cat] = (catDist[cat] ?? 0) + 1;

        final nextDue = (data['nextFollowUpDate'] as Timestamp?)?.toDate();
        if (nextDue != null && nextDue.isBefore(now)) {
          overdue++;
        } else {
          healthy++;
        }
      }

      // Base score 100 minus penalty for overdue ratio
      final overdueRatio = total > 0 ? (overdue / total) : 0.0;
      final calculatedScore = (100 - (overdueRatio * 45)).round().clamp(30, 100);

      // Streak from followups
      final followupsSnap = await _followupsRef(userId).where('isCompleted', isEqualTo: true).get();
      final streak = (followupsSnap.docs.length + 3).clamp(1, 365);

      return RelationshipHealthSummary(
        overallScore: calculatedScore,
        totalRelationships: total,
        healthyCadenceCount: healthy,
        overdueCadenceCount: overdue,
        streakDays: streak,
        categoryDistribution: catDist,
      );
    } catch (e) {
      throw ServerException('Failed to compute health summary: $e');
    }
  }

  @override
  Future<void> generateSmartInsights(String userId) async {
    try {
      if (userId.isEmpty) return;

      final relationshipsSnap = await _relationshipsRef(userId).get();
      final now = DateTime.now();

      for (final doc in relationshipsSnap.docs) {
        final data = doc.data();
        final name = (data['fullName'] as String?) ?? 'Friend';
        final nextDue = (data['nextFollowUpDate'] as Timestamp?)?.toDate();

        if (nextDue != null && now.difference(nextDue).inDays >= 5) {
          // Check if insight already generated
          final existing = await _insightsRef(userId)
              .where('targetRelationshipId', isEqualTo: doc.id)
              .where('isDismissed', isEqualTo: false)
              .limit(1)
              .get();

          if (existing.docs.isEmpty) {
            final daysAgo = now.difference(nextDue).inDays;
            await _insightsRef(userId).add({
              'title': 'Drifting Connection: $name',
              'summary': 'It has been $daysAgo days past your desired cadence to check in with $name. Nurturing bonds takes regular small touchpoints.',
              'actionLabel': 'Schedule Call',
              'type': 'drift',
              'priority': 'high',
              'targetRelationshipId': doc.id,
              'targetContactName': name,
              'isDismissed': false,
              'createdAt': Timestamp.now(),
            });
          }
        }
      }
    } catch (e) {
      throw ServerException('Failed to generate insights: $e');
    }
  }

  @override
  Future<void> dismissInsight(String userId, String insightId) async {
    try {
      await _insightsRef(userId).doc(insightId).update({'isDismissed': true});
    } catch (e) {
      throw ServerException('Failed to dismiss insight: $e');
    }
  }
}
