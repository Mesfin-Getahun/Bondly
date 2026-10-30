import '../entities/insights_entity.dart';

/// Feature: Insights - Repository Interface
abstract class InsightsRepository {
  /// Stream private recommendations & insights for user
  Stream<List<InsightEntity>> watchInsights(String userId);

  /// Compute real-time relationship health metrics
  Future<RelationshipHealthSummary> computeHealthSummary(String userId);

  /// Run local intelligent analysis to generate proactive insights
  Future<void> generateSmartInsights(String userId);

  /// Dismiss an insight recommendation
  Future<void> dismissInsight(String userId, String insightId);
}
