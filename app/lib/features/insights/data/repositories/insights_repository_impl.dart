import '../../domain/entities/insights_entity.dart';
import '../../domain/repositories/insights_repository.dart';
import '../datasources/insights_remote_data_source.dart';

/// Feature: Insights - Repository Implementation
class InsightsRepositoryImpl implements InsightsRepository {
  final InsightsRemoteDataSource _remoteDataSource;

  InsightsRepositoryImpl({InsightsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirestoreInsightsRemoteDataSourceImpl();

  @override
  Stream<List<InsightEntity>> watchInsights(String userId) {
    return _remoteDataSource.watchInsights(userId);
  }

  @override
  Future<RelationshipHealthSummary> computeHealthSummary(String userId) {
    return _remoteDataSource.computeHealthSummary(userId);
  }

  @override
  Future<void> generateSmartInsights(String userId) {
    return _remoteDataSource.generateSmartInsights(userId);
  }

  @override
  Future<void> dismissInsight(String userId, String insightId) {
    return _remoteDataSource.dismissInsight(userId, insightId);
  }
}
