import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schat/constants.dart';
import 'package:schat/controllers/auth_controller.dart';
import 'package:schat/models/message_model.dart';
import 'package:schat/widgets/avatar.dart';
import 'package:schat/widgets/bubble_text.dart';
import 'package:schat/widgets/dismissible_bubble.dart';
import 'package:schat/widgets/media_view.dart';
import 'package:schat/widgets/seen_status.dart';
import 'package:schat/widgets/video_player.dart';

AuthController authController = Get.put(AuthController());

class MediaBubble extends StatelessWidget {
  final MessageModel message;
  final Function onReplied;
  final String avatarImageUrl;

  const MediaBubble({
    Key? key,
    required this.message,
    required this.onReplied,
    required this.avatarImageUrl,
  }) : super(key: key);

  void navToImageView(BuildContext context) {
    Get.to(()=> MediaView(url: message.mediaUrl!, type:message.mediaType!),transition: Transition.zoom,);
  }
    

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMe =
    authController.firebaseUser.value!.uid == message.fromId;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) Avatar(imageUrl: avatarImageUrl),
        if (!isMe) SizedBox(width: 5),
        Flexible(
          child: Hero(
            tag: message.mediaUrl!,
            child: DismssibleBubble(
              isMe: isMe,
              message: message,
              onDismissed: onReplied,
              child: GestureDetector(
                onTap: () => navToImageView(context),
                child: Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: isMe ? null : (message.type == MessageType.Media && message.content != null) ?  Border.all(color: kBorderColor3) : null,
                      color: isMe ? kBlackColor3 : kBlackColor,
                    ),
                    padding: const EdgeInsets.all(5),
                    constraints: BoxConstraints(
                      minWidth: size.width * 0.7,
                      maxWidth: size.width * 0.7,
                      minHeight: size.height * 0.35,
                      // maxHeight: mq.size.height * 0.35,
                    ),
                    child: message.content == null || message.content.isEmpty
                        ? _WithoutText(message: message, isMe: isMe)
                        : _WithText(message: message, isMe: isMe),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WithText extends StatelessWidget {
  const _WithText({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  final MessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      alignment: WrapAlignment.end,
      runAlignment: WrapAlignment.spaceBetween,
      children: [
        Wrap(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                constraints: BoxConstraints(
                  minWidth: size.width * 0.7,
                  maxWidth: size.width * 0.7,
                  minHeight: size.height * 0.35,
                  maxHeight: size.height * 0.35,
                ),
                child: CachedNetworkImage(
                  imageUrl: message.mediaUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: BubbleText(text: message.content)),
          ],
        ),
        SeenStatus(
          isMe: isMe,
          isSeen: message.isSeen,
          timestamp: message.sendDate,
        ),
      ],
    );
  }
}

class _WithoutText extends StatelessWidget {
  const _WithoutText({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  final MessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          constraints: BoxConstraints(
            minWidth: size.width * 0.7,
            maxWidth: size.width * 0.7,
            minHeight: size.height * 0.35,
            maxHeight: size.height * 0.35,
          ),
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: message.mediaType == MediaType.Video
              ? CVideoPlayer(
                  url: message.mediaUrl,
                  isLocal: false,
                )
              : CachedNetworkImage(
                  imageUrl: message.mediaUrl!,
                  placeholder: (_, __) => Center(child: CupertinoActivityIndicator()),                 
                  fit: BoxFit.cover,
                ),
          ),
           
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                          child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(5),
                height: 30,
                constraints: BoxConstraints(
                  maxWidth: size.width * 0.8,
                ),
                width: double.infinity,
                decoration: BoxDecoration(                 
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.01),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: SeenStatus(
                  isMe: isMe,
                  isSeen: message.isSeen,
                  timestamp: message.sendDate,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
