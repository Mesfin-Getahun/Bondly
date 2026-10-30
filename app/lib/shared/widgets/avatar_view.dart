import 'package:flutter/material.dart';

class AvatarView extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;

  const AvatarView({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: radius,
      child: Text(initial),
    );
  }
}
