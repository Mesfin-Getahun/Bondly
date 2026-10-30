/// Feature: Reports - Data Model
/// User reports and moderation.
class ReportsModel {
  final String id;
  const ReportsModel({required this.id});

  Map<String, dynamic> toMap() => {'id': id};
  factory ReportsModel.fromMap(Map<String, dynamic> map) => ReportsModel(id: map['id'] ?? '');
}
