import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schat/constants.dart';
import 'package:schat/models/message_model.dart';
import 'package:schat/models/user_model.dart';
import 'package:schat/widgets/avatar.dart';
import 'package:schat/widgets/bubble_text.dart';
import 'package:schat/widgets/reply_bubble.dart';
import 'package:schat/widgets/dismissible_bubble.dart';
import 'package:schat/widgets/media_bubble.dart';
import 'package:schat/widgets/seen_status.dart';


class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final UserModel peer;
  final bool withoutAvatar;
  final Function? onReply;
  ChatBubble({
    required this.message,
    required this.isMe,
    required this.peer,
    required this.withoutAvatar,
    this.onReply,
  }) : super();

  Widget chatItem(BuildContext context) {
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          if (message.type == MessageType.Text) {
            return !isMe
                ? _PeerMessage(
                    peer: peer,
                    isMe: isMe,
                    message: message,
                    onReplyPressed: onReply!,
                    constraints: constraints,
                    withoutAvatar: withoutAvatar,
                  )
                : _WithoutAvatar(
                    isMe: isMe,
                    message: message,
                    onReplyPressed: onReply!,
                    peer: peer,
                    constraints: constraints,
                  );
          } else {
            return MediaBubble(
              message: message,
              onReplied: onReply!,
              avatarImageUrl: peer.imageUrl!,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return chatItem(context);
  }
}

class _PeerMessage extends StatelessWidget {
  const _PeerMessage({
    Key? key,
    required this.peer,
    required this.isMe,
    required this.message,
    required this.onReplyPressed,
    required this.constraints,
    required this.withoutAvatar,
  }) : super(key: key);

  final UserModel peer;
  final bool isMe;
  final MessageModel message;
  final Function onReplyPressed;
  final BoxConstraints constraints;
  final bool withoutAvatar;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        withoutAvatar ? SizedBox(width: 30) :Avatar(imageUrl:peer.imageUrl!),
        SizedBox(width: 5),
        _WithoutAvatar(
          isMe: isMe,
          message: message,
          onReplyPressed: onReplyPressed,
          peer: peer,
          constraints: constraints,
        ),
      ],
    );
  }
}

class _WithoutAvatar extends StatelessWidget {
  const _WithoutAvatar({
    Key? key,
    required this.isMe,
    required this.message,
    required this.onReplyPressed,
    required this.peer,
    required this.constraints,
  }) : super(key: key);

  final bool isMe;
  final MessageModel message;
  final Function onReplyPressed;
  final UserModel peer;
  final BoxConstraints constraints;

  BorderRadius _replyMsgRadius() {
    if (message.reply != null) {
      if (isMe)
        return BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        );
      return BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
        topRight: Radius.circular(20),
      );
    }

    return BorderRadius.circular(20);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DismssibleBubble(
      isMe: isMe,
      message: message,
      onDismissed: onReplyPressed,
      child: Wrap(
        children: [
          Stack(
            children: [
              if (message.reply != null)
                Align(
                  alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                  child: ReplyMessageBubble(
                    message: message,
                    peer: peer,
                  ),
                ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  // key: key,
                  margin: message.reply != null
                      ? EdgeInsets.only(
                          top: (message.reply != null &&
                                  message.reply!.type == MessageType.Text)
                              ? 50
                              : message.mediaType==MediaType.Photo? size.height * 0.25 - 5 :message.reply != null? message.reply!.mediaType==MediaType.Photo? size.height * 0.25:60:60,
                        )
                      : const EdgeInsets.all(0),
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: _replyMsgRadius(),
                    border: isMe ? null : Border.all(color: kBorderColor3),
                    color: isMe ? kBlackColor3 : kBlackColor,
                  ),
                  child: Padding(
                    key: key,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      runAlignment: WrapAlignment.end,
                      alignment: WrapAlignment.end,
                      spacing: 20,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 12),
                          child: BubbleText(text: message.content),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: SeenStatus(
                            isMe: isMe,
                            isSeen: message.isSeen,
                            timestamp: message.sendDate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
