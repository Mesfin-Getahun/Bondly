import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/auth_entity.dart';

/// Feature: Auth - Data Model
/// Serializes authentication user data and adapts Firebase User instances.
class AuthModel extends AuthEntity {
  const AuthModel({
    required super.id,
    super.email,
    super.displayName,
    super.photoUrl,
    super.isAnonymous,
  });

  factory AuthModel.fromFirebaseUser(fb.User user) {
    return AuthModel(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
    );
  }

  factory AuthModel.fromMap(Map<String, dynamic> map) {
    return AuthModel(
      id: map['id'] ?? map['uid'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      isAnonymous: map['isAnonymous'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isAnonymous': isAnonymous,
    };
  }
}
