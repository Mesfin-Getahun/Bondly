/// Feature: Projects - Data Model
/// Projects, tasks, and milestones.
class ProjectsModel {
  final String id;
  const ProjectsModel({required this.id});

  Map<String, dynamic> toMap() => {'id': id};
  factory ProjectsModel.fromMap(Map<String, dynamic> map) => ProjectsModel(id: map['id'] ?? '');
}
