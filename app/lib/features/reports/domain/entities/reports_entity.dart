/// Feature: Reports - Domain Entity
///
/// User reports, safety flags, and community moderation records.
library;

import 'package:flutter/material.dart';

class ReportEntity {
  final String id;
  final String reporterId;
  final String reporterName;
  final String? targetUserId;
  final String? targetUserName;
  final String targetType; // 'user' | 'message' | 'group' | 'content'
  final String reason; // 'Harassment', 'Spam', 'Impersonation', 'Inappropriate Content', 'Privacy Breach', 'Other'
  final String description;
  final String status; // 'pending' | 'under_review' | 'resolved' | 'dismissed'
  final String? resolutionNotes;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const ReportEntity({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    this.targetUserId,
    this.targetUserName,
    this.targetType = 'user',
    required this.reason,
    required this.description,
    this.status = 'pending',
    this.resolutionNotes,
    required this.createdAt,
    this.resolvedAt,
  });

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'under_review':
        return Colors.blue;
      case 'dismissed':
        return Colors.grey;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'under_review':
        return 'Under Review';
      case 'resolved':
        return 'Resolved';
      case 'dismissed':
        return 'Dismissed';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  ReportEntity copyWith({
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
    return ReportEntity(
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
}
