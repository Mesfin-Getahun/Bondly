/// Feature: Privacy - Domain Entity
///
/// Privacy settings, consent management, data export records, and deletion requests.
library;

class PrivacySettingsEntity {
  final String userId;
  final bool searchVisibility;
  final bool analyticsConsent;
  final bool personalizedRecommendations;
  final bool readReceipts;
  final bool lastActiveVisibility;
  final DateTime updatedAt;

  const PrivacySettingsEntity({
    required this.userId,
    this.searchVisibility = true,
    this.analyticsConsent = true,
    this.personalizedRecommendations = true,
    this.readReceipts = true,
    this.lastActiveVisibility = true,
    required this.updatedAt,
  });

  PrivacySettingsEntity copyWith({
    String? userId,
    bool? searchVisibility,
    bool? analyticsConsent,
    bool? personalizedRecommendations,
    bool? readReceipts,
    bool? lastActiveVisibility,
    DateTime? updatedAt,
  }) {
    return PrivacySettingsEntity(
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
}

class DataExportEntity {
  final String id;
  final String userId;
  final String status;
  final String jsonData;
  final DateTime exportedAt;

  const DataExportEntity({
    required this.id,
    required this.userId,
    required this.status,
    required this.jsonData,
    required this.exportedAt,
  });
}
