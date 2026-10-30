import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/privacy_model.dart';

/// Feature: Privacy - Remote Data Source Interface
abstract class PrivacyRemoteDataSource {
  Stream<PrivacySettingsModel> watchPrivacySettings(String userId);
  Future<void> updatePrivacySettings(PrivacySettingsModel settings);
  Future<String> exportUserData(String userId);
  Future<void> deleteUserAccountAndData(String userId);
}

/// Implementation using Cloud Firestore & Firebase Auth
class FirestorePrivacyRemoteDataSourceImpl implements PrivacyRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestorePrivacyRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> _privacyDoc(String userId) =>
      _firestore.collection(FirestoreCollections.users).doc(userId).collection('privacy').doc('settings');

  @override
  Stream<PrivacySettingsModel> watchPrivacySettings(String userId) {
    if (userId.isEmpty) {
      return Stream.value(PrivacySettingsModel(userId: '', updatedAt: DateTime.now()));
    }

    return _privacyDoc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        return PrivacySettingsModel(userId: userId, updatedAt: DateTime.now());
      }
      return PrivacySettingsModel.fromFirestore(doc, userId);
    });
  }

  @override
  Future<void> updatePrivacySettings(PrivacySettingsModel settings) async {
    try {
      final doc = _privacyDoc(settings.userId);
      await doc.set(settings.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Failed to update privacy settings: $e');
    }
  }

  @override
  Future<String> exportUserData(String userId) async {
    try {
      final Map<String, dynamic> exportPackage = {
        'exportDate': DateTime.now().toIso8601String(),
        'userId': userId,
      };

      // 1. User profile
      final userDoc = await _firestore.collection(FirestoreCollections.users).doc(userId).get();
      if (userDoc.exists) {
        exportPackage['profile'] = userDoc.data();
      }

      // 2. Private Relationships
      final relationshipsSnap = await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection(FirestoreCollections.relationships)
          .get();
      exportPackage['relationships'] = relationshipsSnap.docs.map((d) => d.data()).toList();

      // 3. Private Follow-ups
      final followupsSnap = await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection(FirestoreCollections.followups)
          .get();
      exportPackage['followups'] = followupsSnap.docs.map((d) => d.data()).toList();

      // 4. Goals
      final goalsSnap = await _firestore
          .collection(FirestoreCollections.goals)
          .where('participantIds', arrayContains: userId)
          .get();
      exportPackage['goals'] = goalsSnap.docs.map((d) => d.data()).toList();

      return const JsonEncoder.withIndent('  ').convert(exportPackage);
    } catch (e) {
      throw ServerException('Failed to export user data: $e');
    }
  }

  @override
  Future<void> deleteUserAccountAndData(String userId) async {
    try {
      // 1. Delete private subcollections
      final userRef = _firestore.collection(FirestoreCollections.users).doc(userId);

      final rels = await userRef.collection(FirestoreCollections.relationships).get();
      for (final doc in rels.docs) {
        await doc.reference.delete();
      }

      final followups = await userRef.collection(FirestoreCollections.followups).get();
      for (final doc in followups.docs) {
        await doc.reference.delete();
      }

      final privacy = await userRef.collection('privacy').get();
      for (final doc in privacy.docs) {
        await doc.reference.delete();
      }

      // 2. Delete main user profile
      await userRef.delete();

      // 3. Delete Firebase Auth user if authenticated
      if (_auth.currentUser != null && _auth.currentUser!.uid == userId) {
        await _auth.currentUser!.delete();
      }
    } catch (e) {
      throw ServerException('Failed to complete account deletion: $e');
    }
  }
}
