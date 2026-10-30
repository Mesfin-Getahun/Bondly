import '../entities/insights_entity.dart';
import '../repositories/insights_repository.dart';

/// Stream private insights
class WatchInsightsUseCase {
  final InsightsRepository repository;
  WatchInsightsUseCase(this.repository);

  Stream<List<InsightEntity>> call(String userId) {
    return repository.watchInsights(userId);
  }
}

/// Compute relationship health summary
class ComputeHealthSummaryUseCase {
  final InsightsRepository repository;
  ComputeHealthSummaryUseCase(this.repository);

  Future<RelationshipHealthSummary> call(String userId) {
    return repository.computeHealthSummary(userId);
  }
}

/// Generate smart proactive insights
class GenerateSmartInsightsUseCase {
  final InsightsRepository repository;
  GenerateSmartInsightsUseCase(this.repository);

  Future<void> call(String userId) {
    return repository.generateSmartInsights(userId);
  }
}

/// Dismiss an insight
class DismissInsightUseCase {
  final InsightsRepository repository;
  DismissInsightUseCase(this.repository);

  Future<void> call(String userId, String insightId) {
    return repository.dismissInsight(userId, insightId);
  }
}
