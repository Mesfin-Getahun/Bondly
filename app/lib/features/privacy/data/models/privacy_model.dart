import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/privacy_entity.dart';

/// Feature: Privacy - Settings Model
class PrivacySettingsModel extends PrivacySettingsEntity {
  const PrivacySettingsModel({
    required super.userId,
    super.searchVisibility = true,
    super.analyticsConsent = true,
    super.personalizedRecommendations = true,
    super.readReceipts = true,
    super.lastActiveVisibility = true,
    required super.updatedAt,
  });

  factory PrivacySettingsModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, String userId) {
    final data = doc.data() ?? {};
    return PrivacySettingsModel(
      userId: userId,
      searchVisibility: data['searchVisibility'] as bool? ?? true,
      analyticsConsent: data['analyticsConsent'] as bool? ?? true,
      personalizedRecommendations: data['personalizedRecommendations'] as bool? ?? true,
      readReceipts: data['readReceipts'] as bool? ?? true,
      lastActiveVisibility: data['lastActiveVisibility'] as bool? ?? true,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'searchVisibility': searchVisibility,
      'analyticsConsent': analyticsConsent,
      'personalizedRecommendations': personalizedRecommendations,
      'readReceipts': readReceipts,
      'lastActiveVisibility': lastActiveVisibility,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  PrivacySettingsModel copyWith({
    String? userId,
    bool? searchVisibility,
    bool? analyticsConsent,
    bool? personalizedRecommendations,
    bool? readReceipts,
    bool? lastActiveVisibility,
    DateTime? updatedAt,
  }) {
    return PrivacySettingsModel(
      userId: userId ?? this.userId,
      searchVisibility: searchVisibility ?? this.searchVisibility,
      analyticsConsent: analyticsConsent ?? this.analyticsConsent,
      personalizedRecommendations:
          personalizedRecommendations ?? this.personalizedRecommendations,
      readReceipts: readReceipts ?? this.readReceipts,
      lastActiveVisibility: lastActiveVisibility ?? this.lastActiveVisibility,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PrivacySettingsModel.fromEntity(PrivacySettingsEntity entity) {
    return PrivacySettingsModel(
      userId: entity.userId,
      searchVisibility: entity.searchVisibility,
      analyticsConsent: entity.analyticsConsent,
      personalizedRecommendations: entity.personalizedRecommendations,
      readReceipts: entity.readReceipts,
      lastActiveVisibility: entity.lastActiveVisibility,
      updatedAt: entity.updatedAt,
    );
  }
}
