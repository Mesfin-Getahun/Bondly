import '../entities/reports_entity.dart';
import '../repositories/reports_repository.dart';

/// Stream user's filed reports
class WatchReportsUseCase {
  final ReportsRepository repository;
  WatchReportsUseCase(this.repository);

  Stream<List<ReportEntity>> call(String reporterId) {
    return repository.watchReportsByReporter(reporterId);
  }
}

/// Submit a user report
class SubmitReportUseCase {
  final ReportsRepository repository;
  SubmitReportUseCase(this.repository);

  Future<ReportEntity> call({
    required String reporterId,
    required String reporterName,
    String? targetUserId,
    String? targetUserName,
    String targetType = 'user',
    required String reason,
    required String description,
  }) {
    return repository.submitReport(
      reporterId: reporterId,
      reporterName: reporterName,
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      targetType: targetType,
      reason: reason,
      description: description,
    );
  }
}
