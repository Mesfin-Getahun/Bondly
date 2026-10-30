import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/reports_model.dart';

/// Feature: Reports - Remote Data Source Interface
abstract class ReportsRemoteDataSource {
  Stream<List<ReportModel>> watchReportsByReporter(String reporterId);
  Future<ReportModel> submitReport({
    required String reporterId,
    required String reporterName,
    String? targetUserId,
    String? targetUserName,
    String targetType = 'user',
    required String reason,
    required String description,
  });
}

/// Implementation using Cloud Firestore
class FirestoreReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreReportsRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reportsRef =>
      _firestore.collection(FirestoreCollections.reports);

  @override
  Stream<List<ReportModel>> watchReportsByReporter(String reporterId) {
    if (reporterId.isEmpty) return Stream.value([]);

    return _reportsRef
        .where('reporterId', isEqualTo: reporterId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<ReportModel> submitReport({
    required String reporterId,
    required String reporterName,
    String? targetUserId,
    String? targetUserName,
    String targetType = 'user',
    required String reason,
    required String description,
  }) async {
    try {
      final docRef = _reportsRef.doc();
      final now = DateTime.now();

      final model = ReportModel(
        id: docRef.id,
        reporterId: reporterId,
        reporterName: reporterName,
        targetUserId: targetUserId,
        targetUserName: targetUserName,
        targetType: targetType,
        reason: reason,
        description: description.trim(),
        status: 'pending',
        createdAt: now,
      );

      await docRef.set(model.toFirestore());
      return model;
    } catch (e) {
      throw ServerException('Failed to submit report: $e');
    }
  }
}
