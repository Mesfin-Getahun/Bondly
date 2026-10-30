import '../entities/reports_entity.dart';

/// Feature: Reports - Repository Interface
abstract class ReportsRepository {
  /// Stream reports filed by the current user
  Stream<List<ReportEntity>> watchReportsByReporter(String reporterId);

  /// Submit a new moderation or user report
  Future<ReportEntity> submitReport({
    required String reporterId,
    required String reporterName,
    String? targetUserId,
    String? targetUserName,
    String targetType = 'user',
    required String reason,
    required String description,
  });
}
