import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schat/constants.dart';
import 'package:schat/controllers/theme_controller.dart';
import 'package:schat/widgets/video_player.dart';

ThemeController themeController = Get.put(ThemeController());

class MediaView extends StatelessWidget {
  final String url;
  final MediaType type;
  MediaView({
    required this.url,
    required this.type,
  });
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: themeController.isDarkModeEnabled.value==true?Colors.white.withOpacity(0.9):
          Colors.black.withOpacity(0.9),
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: mq.size.height,
              ),
              height: double.infinity,
              width: double.infinity,
              child: type == MediaType.Photo ?
              CachedNetworkImage(imageUrl: url, fit: BoxFit.contain)
                  : Center(child: CVideoPlayer(url: url, isLocal: false)),
            ),
          ),
        ),
      ),
    );
  }
}
