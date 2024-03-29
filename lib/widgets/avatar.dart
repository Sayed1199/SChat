import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:schat/constants.dart';


class Avatar extends StatelessWidget {
  const Avatar({
    required this.imageUrl,
    this.radius = 15,

    Key? key, this.color=Colors.transparent,
   
  }) : super(key: key);  

  final String imageUrl;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
          backgroundColor: color,
          backgroundImage:
            imageUrl == null || imageUrl == ''
                  ? null
                  : CachedNetworkImageProvider(imageUrl),
          child: imageUrl == null || imageUrl == ''
              ? Icon(Icons.person, color: kBaseWhiteColor)
              : null,
          radius: radius,
        );
  }
}
