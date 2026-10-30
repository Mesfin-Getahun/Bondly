import '../../domain/entities/reports_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_data_source.dart';

/// Feature: Reports - Repository Implementation
class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource _remoteDataSource;

  ReportsRepositoryImpl({ReportsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirestoreReportsRemoteDataSourceImpl();

  @override
  Stream<List<ReportEntity>> watchReportsByReporter(String reporterId) {
    return _remoteDataSource.watchReportsByReporter(reporterId);
  }

  @override
  Future<ReportEntity> submitReport({
    required String reporterId,
    required String reporterName,
    String? targetUserId,
    String? targetUserName,
    String targetType = 'user',
    required String reason,
    required String description,
  }) {
    return _remoteDataSource.submitReport(
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
