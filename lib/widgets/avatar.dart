import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String initals;
  final String avatar;
  final double radius;

  Avatar({
    @required this.initals,
    this.avatar,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      child: (avatar != null && avatar.isNotEmpty)
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatar,
                fit: BoxFit.cover,
              ),
            )
          : Text(initals),
      backgroundColor: (avatar != null && avatar.isNotEmpty)
          ? Colors.transparent
          : Theme.of(context).primaryColorDark,
    );
  }
}
