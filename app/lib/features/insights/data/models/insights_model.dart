/// Feature: Insights - Data Model
/// Relationship insights and AI-powered recommendations.
class InsightsModel {
  final String id;
  const InsightsModel({required this.id});

  Map<String, dynamic> toMap() => {'id': id};
  factory InsightsModel.fromMap(Map<String, dynamic> map) => InsightsModel(id: map['id'] ?? '');
}
