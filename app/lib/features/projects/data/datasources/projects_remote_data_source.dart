import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/projects_entity.dart';
import '../models/projects_model.dart';

/// Feature: Projects - Remote Data Source Interface
abstract class ProjectsRemoteDataSource {
  Stream<List<ProjectModel>> watchUserProjects(String userId);
  Future<ProjectModel?> getProjectById(String projectId);
  Future<ProjectModel> createProject({
    required String title,
    String? description,
    required String creatorId,
    required String creatorName,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    String category = 'Collaboration',
    String status = 'active',
    DateTime? dueDate,
  });
  Future<void> updateProject(ProjectModel project);
  Future<void> addTask(String projectId, ProjectTaskEntity task);
  Future<void> toggleTask(String projectId, String taskId, bool isCompleted);
  Future<void> deleteTask(String projectId, String taskId);
  Future<void> addMilestone(String projectId, ProjectMilestoneEntity milestone);
  Future<void> toggleMilestone(String projectId, String milestoneId, bool isReached);
  Future<void> deleteProject(String projectId);
}

/// Implementation using Cloud Firestore
class FirestoreProjectsRemoteDataSourceImpl implements ProjectsRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreProjectsRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _projectsRef =>
      _firestore.collection(FirestoreCollections.projects);

  @override
  Stream<List<ProjectModel>> watchUserProjects(String userId) {
    if (userId.isEmpty) return Stream.value([]);

    return _projectsRef
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    });
  }

  @override
  Future<ProjectModel?> getProjectById(String projectId) async {
    try {
      final doc = await _projectsRef.doc(projectId).get();
      if (!doc.exists) return null;
      return ProjectModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to fetch project: $e');
    }
  }

  @override
  Future<ProjectModel> createProject({
    required String title,
    String? description,
    required String creatorId,
    required String creatorName,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    String category = 'Collaboration',
    String status = 'active',
    DateTime? dueDate,
  }) async {
    try {
      final docRef = _projectsRef.doc();
      final now = DateTime.now();

      final allParticipants = [
        creatorId,
        if (participantIds != null) ...participantIds.where((id) => id != creatorId),
      ];

      final allNames = {
        creatorId: creatorName,
        if (participantNames != null) ...participantNames,
      };

      final model = ProjectModel(
        id: docRef.id,
        title: title.trim(),
        description: description?.trim().isNotEmpty == true ? description!.trim() : null,
        creatorId: creatorId,
        creatorName: creatorName,
        participantIds: allParticipants,
        participantNames: allNames,
        category: category,
        status: status,
        dueDate: dueDate,
        tasks: const [],
        milestones: const [],
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(model.toFirestore());
      return model;
    } catch (e) {
      throw ServerException('Failed to create project: $e');
    }
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    try {
      await _projectsRef.doc(project.id).update({
        'title': project.title,
        'description': project.description,
        'category': project.category,
        'status': project.status,
        'dueDate': project.dueDate != null ? Timestamp.fromDate(project.dueDate!) : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to update project: $e');
    }
  }

  @override
  Future<void> addTask(String projectId, ProjectTaskEntity task) async {
    try {
      final doc = await _projectsRef.doc(projectId).get();
      if (!doc.exists) throw ServerException('Project not found');

      final current = ProjectModel.fromFirestore(doc);
      final updatedTasks = [...current.tasks, task];

      await _projectsRef.doc(projectId).update({
        'tasks': updatedTasks.map((t) => ProjectTaskModel.fromEntity(t).toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to add task: $e');
    }
  }

  @override
  Future<void> toggleTask(String projectId, String taskId, bool isCompleted) async {
    try {
      final doc = await _projectsRef.doc(projectId).get();
      if (!doc.exists) throw ServerException('Project not found');

      final current = ProjectModel.fromFirestore(doc);
      final updatedTasks = current.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(isCompleted: isCompleted);
        }
        return t;
      }).toList();

      await _projectsRef.doc(projectId).update({
        'tasks': updatedTasks.map((t) => ProjectTaskModel.fromEntity(t).toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to toggle task: $e');
    }
  }

  @override
  Future<void> deleteTask(String projectId, String taskId) async {
    try {
      final doc = await _projectsRef.doc(projectId).get();
      if (!doc.exists) throw ServerException('Project not found');

      final current = ProjectModel.fromFirestore(doc);
      final updatedTasks = current.tasks.where((t) => t.id != taskId).toList();

      await _projectsRef.doc(projectId).update({
        'tasks': updatedTasks.map((t) => ProjectTaskModel.fromEntity(t).toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to delete task: $e');
    }
  }

  @override
  Future<void> addMilestone(String projectId, ProjectMilestoneEntity milestone) async {
    try {
      final doc = await _projectsRef.doc(projectId).get();
      if (!doc.exists) throw ServerException('Project not found');

      final current = ProjectModel.fromFirestore(doc);
      final updatedMilestones = [...current.milestones, milestone];

      await _projectsRef.doc(projectId).update({
        'milestones': updatedMilestones
            .map((m) => ProjectMilestoneModel.fromEntity(m).toMap())
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to add milestone: $e');
    }
  }

  @override
  Future<void> toggleMilestone(String projectId, String milestoneId, bool isReached) async {
    try {
      final doc = await _projectsRef.doc(projectId).get();
      if (!doc.exists) throw ServerException('Project not found');

      final current = ProjectModel.fromFirestore(doc);
      final updatedMilestones = current.milestones.map((m) {
        if (m.id == milestoneId) {
          return m.copyWith(isReached: isReached);
        }
        return m;
      }).toList();

      await _projectsRef.doc(projectId).update({
        'milestones': updatedMilestones
            .map((m) => ProjectMilestoneModel.fromEntity(m).toMap())
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to toggle milestone: $e');
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      await _projectsRef.doc(projectId).delete();
    } catch (e) {
      throw ServerException('Failed to delete project: $e');
    }
  }
}
