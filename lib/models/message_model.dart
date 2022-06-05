import 'package:schat/constants.dart';
import 'package:schat/models/reply_message_model.dart';

class MessageModel{

  final String content;
  final String fromId;
  final String toId;
  final String timeStamp;
  final DateTime sendDate;
  final bool isSeen;
  final MessageType type;
  MediaType? mediaType;
  String? mediaUrl;
  bool? uploadFinished;
  ReplyMessageModel? reply;

  MessageModel({
  required this.content,
  required this.fromId,
  required this.toId,
  required this.timeStamp,
  required this.sendDate,
  required this.isSeen,
  required this.type,
  this.mediaType,
  this.mediaUrl,
  this.uploadFinished,
  this.reply
  });

  factory MessageModel.fromJson(Map<String,dynamic>data){
    return MessageModel(
        content: data['content'],
        fromId:  data['fromId'],
        toId:  data['toId'],
        timeStamp:  data['timeStamp'].toString(),
        sendDate:  DateTime.parse(data['sendDate']),
        isSeen:  data['isSeen'],
        type:  data['type']=='MessageType.Text'?MessageType.Text:MessageType.Media,
        mediaType: data['mediaType']=='MediaType.Photo'?MediaType.Photo:
        data['mediaType']=='MediaType.Video'?MediaType.Video:
        data['mediaType']=='MediaType.Audio'?MediaType.Audio:null,
        mediaUrl: data['mediaUrl'],
        uploadFinished: data['uploadFinished'],
        reply: data['reply']==null?null:ReplyMessageModel.fromJson(data['reply'])
    );
  }


  static Map<String,dynamic> toJson(MessageModel model){

    return {
      'content':model.content,
      'fromId':model.fromId,
      'toId':model.toId,
      'timeStamp':model.timeStamp,
      'sendDate':model.sendDate.toIso8601String(),
      'isSeen':model.isSeen,
      'type':model.type.toString(),
      'mediaType':model.mediaType.toString(),
      'mediaUrl':model.mediaUrl,
      'uploadFinished':model.uploadFinished,
      'reply':model.reply==null?null: ReplyMessageModel.toJson(model.reply!)

    };
  }

















}