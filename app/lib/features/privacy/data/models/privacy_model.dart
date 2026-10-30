/// Feature: Privacy - Data Model
/// Privacy settings, data export, consent, and account deletion.
class PrivacyModel {
  final String id;
  const PrivacyModel({required this.id});

  Map<String, dynamic> toMap() => {'id': id};
  factory PrivacyModel.fromMap(Map<String, dynamic> map) => PrivacyModel(id: map['id'] ?? '');
}
