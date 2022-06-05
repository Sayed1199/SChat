import 'package:schat/models/message_model.dart';

class MediaModel{

  final String url;
  final String fromId;
  final String toId;
  final DateTime timeStamp;

  MediaModel({
  required this.url,
  required this.fromId,
  required this.toId,
  required this.timeStamp
  });

  factory MediaModel.fromJson(Map<String,dynamic>data){
    return MediaModel(
        url: data['url'],
        fromId: data['fromId'],
        toId: data['toId'],
        timeStamp: DateTime.parse(data['timeStamp']));
  }

  static Map<String,dynamic> toJson(MediaModel model){
    return {
      'url':model.url,
      'fromId':model.fromId,
      'toId':model.toId,
      'timeStamp':model.timeStamp.toIso8601String()
    };
  }

  static fromMsgToMap(MessageModel msg) => {
    'url': msg.mediaUrl,
    'fromId': msg.fromId,
    'toId': msg.toId,
    'timeStamp': msg.sendDate,
  };

}