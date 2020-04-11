import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Avatar extends StatelessWidget {
  final String initals;
  final String avatar;

  Avatar({
    @required this.initals,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
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
          : Theme.of(context).accentColor,
    );
  }
}
