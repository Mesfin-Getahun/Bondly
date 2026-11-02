import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/users_model.dart';

/// Feature: Users - Remote Data Source Interface
abstract class UsersRemoteDataSource {
  Future<UserProfileModel?> getUserProfile(String userId);
  Stream<UserProfileModel?> watchUserProfile(String userId);
  Future<void> updateUserProfile(UserProfileModel profile);
  Future<void> updateSettings({
    required String userId,
    int? defaultCadenceDays,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? isPrivate,
  });
}

/// Implementation using Cloud Firestore
class FirestoreUsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final FirebaseFirestore _firestore;

  static UserProfileModel _guestDemoProfile = UserProfileModel(
    id: 'guest_demo_user',
    email: 'guest@bondly.app',
    displayName: 'Alex Morgan',
    bio: 'Product builder, coffee enthusiast, and lifelong learner.',
    defaultCadenceDays: 14,
    pushNotifications: true,
    emailNotifications: true,
    isPrivate: false,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );

  FirestoreUsersRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(FirestoreCollections.users);

  @override
  Future<UserProfileModel?> getUserProfile(String userId) async {
    if (userId == 'guest_demo_user') {
      return _guestDemoProfile;
    }
    try {
      final doc = await _usersRef.doc(userId).get();
      if (!doc.exists) return null;
      return UserProfileModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to load user profile: $e');
    }
  }

  @override
  Stream<UserProfileModel?> watchUserProfile(String userId) {
    if (userId.isEmpty) return Stream.value(null);
    if (userId == 'guest_demo_user') {
      return Stream.value(_guestDemoProfile);
    }

    return _usersRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfileModel.fromFirestore(doc);
    });
  }

  @override
  Future<void> updateUserProfile(UserProfileModel profile) async {
    if (profile.id == 'guest_demo_user') {
      _guestDemoProfile = profile;
      return;
    }
    try {
      final data = profile.toFirestore()..['updatedAt'] = FieldValue.serverTimestamp();
      await _usersRef.doc(profile.id).set(data, SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> updateSettings({
    required String userId,
    int? defaultCadenceDays,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? isPrivate,
  }) async {
    if (userId == 'guest_demo_user') {
      _guestDemoProfile = UserProfileModel(
        id: _guestDemoProfile.id,
        email: _guestDemoProfile.email,
        displayName: _guestDemoProfile.displayName,
        photoUrl: _guestDemoProfile.photoUrl,
        bio: _guestDemoProfile.bio,
        phoneNumber: _guestDemoProfile.phoneNumber,
        defaultCadenceDays: defaultCadenceDays ?? _guestDemoProfile.defaultCadenceDays,
        pushNotifications: pushNotifications ?? _guestDemoProfile.pushNotifications,
        emailNotifications: emailNotifications ?? _guestDemoProfile.emailNotifications,
        isPrivate: isPrivate ?? _guestDemoProfile.isPrivate,
        createdAt: _guestDemoProfile.createdAt,
        updatedAt: DateTime.now(),
      );
      return;
    }
    try {
      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (defaultCadenceDays != null) updates['defaultCadenceDays'] = defaultCadenceDays;
      if (pushNotifications != null) updates['pushNotifications'] = pushNotifications;
      if (emailNotifications != null) updates['emailNotifications'] = emailNotifications;
      if (isPrivate != null) updates['isPrivate'] = isPrivate;

      await _usersRef.doc(userId).update(updates);
    } catch (e) {
      throw ServerException('Failed to update settings: $e');
    }
  }
}
