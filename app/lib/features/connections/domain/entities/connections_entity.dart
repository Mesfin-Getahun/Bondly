/// Feature: Connections - Domain Entity
/// Friend requests, mutual connections, and blocking.
library;

enum ConnectionStatus {
  pending,
  accepted,
  declined,
  blocked;

  static ConnectionStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'accepted':
        return ConnectionStatus.accepted;
      case 'declined':
        return ConnectionStatus.declined;
      case 'blocked':
        return ConnectionStatus.blocked;
      case 'pending':
      default:
        return ConnectionStatus.pending;
    }
  }

  String toDbString() => name;
}

class ConnectionEntity {
  final String id;
  final String userA; // Requester UID
  final String userB; // Recipient UID
  final String userAName;
  final String userBName;
  final String? userAAvatar;
  final String? userBAvatar;
  final ConnectionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConnectionEntity({
    required this.id,
    required this.userA,
    required this.userB,
    required this.userAName,
    required this.userBName,
    this.userAAvatar,
    this.userBAvatar,
    this.status = ConnectionStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  String otherUserId(String currentUserId) {
    return currentUserId == userA ? userB : userA;
  }

  String otherUserName(String currentUserId) {
    return currentUserId == userA ? userBName : userAName;
  }

  String? otherUserAvatar(String currentUserId) {
    return currentUserId == userA ? userBAvatar : userAAvatar;
  }

  bool isPendingForMe(String currentUserId) {
    return status == ConnectionStatus.pending && userB == currentUserId;
  }

  bool isSentByMe(String currentUserId) {
    return userA == currentUserId;
  }

  bool isAccepted() => status == ConnectionStatus.accepted;
}
