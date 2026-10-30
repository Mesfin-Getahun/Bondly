/// Feature: Goals - Data Model
/// Personal and shared goals.
class GoalsModel {
  final String id;
  const GoalsModel({required this.id});

  Map<String, dynamic> toMap() => {'id': id};
  factory GoalsModel.fromMap(Map<String, dynamic> map) => GoalsModel(id: map['id'] ?? '');
}
