import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reports_entity.dart';

/// Feature: Reports - Data Model
class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.reporterId,
    required super.reporterName,
    super.targetUserId,
    super.targetUserName,
    super.targetType = 'user',
    required super.reason,
    required super.description,
    super.status = 'pending',
    super.resolutionNotes,
    required super.createdAt,
    super.resolvedAt,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ReportModel(
      id: doc.id,
      reporterId: data['reporterId'] as String? ?? '',
      reporterName: data['reporterName'] as String? ?? '',
      targetUserId: data['targetUserId'] as String?,
      targetUserName: data['targetUserName'] as String?,
      targetType: data['targetType'] as String? ?? 'user',
      reason: data['reason'] as String? ?? 'Other',
      description: data['description'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      resolutionNotes: data['resolutionNotes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reporterId': reporterId,
      'reporterName': reporterName,
      'targetUserId': targetUserId,
      'targetUserName': targetUserName,
      'targetType': targetType,
      'reason': reason,
      'description': description,
      'status': status,
      'resolutionNotes': resolutionNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  @override
  ReportModel copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    String? targetUserId,
    String? targetUserName,
    String? targetType,
    String? reason,
    String? description,
    String? status,
    String? resolutionNotes,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      targetUserId: targetUserId ?? this.targetUserId,
      targetUserName: targetUserName ?? this.targetUserName,
      targetType: targetType ?? this.targetType,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  factory ReportModel.fromEntity(ReportEntity entity) {
    return ReportModel(
      id: entity.id,
      reporterId: entity.reporterId,
      reporterName: entity.reporterName,
      targetUserId: entity.targetUserId,
      targetUserName: entity.targetUserName,
      targetType: entity.targetType,
      reason: entity.reason,
      description: entity.description,
      status: entity.status,
      resolutionNotes: entity.resolutionNotes,
      createdAt: entity.createdAt,
      resolvedAt: entity.resolvedAt,
    );
  }
}
