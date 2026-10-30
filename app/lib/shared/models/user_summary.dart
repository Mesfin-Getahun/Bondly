class UserSummary {
  final String id;
  final String displayName;
  final String? photoUrl;

  const UserSummary({
    required this.id,
    required this.displayName,
    this.photoUrl,
  });

  factory UserSummary.fromMap(Map<String, dynamic> map) {
    return UserSummary(
      id: map['id'] as String? ?? '',
      displayName: map['display_name'] as String? ?? 'User',
      photoUrl: map['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'display_name': displayName,
      'photo_url': photoUrl,
    };
  }
}
