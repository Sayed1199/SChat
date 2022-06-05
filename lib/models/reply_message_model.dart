import 'package:schat/constants.dart';

class ReplyMessageModel{

  final String content;
  final String replierId;
  final String repliedToId;
  final MessageType type;
  final MediaType? mediaType;

  ReplyMessageModel({
    required this.content,
    required this.replierId,
    required this.repliedToId,
    required this.type,
    required this.mediaType
  });

  factory ReplyMessageModel.fromJson(Map<String,dynamic> data){
    return ReplyMessageModel(
        content: data['content'],
        replierId: data['replierId'],
        repliedToId: data['repliedToId'],
        type: data['type']=='MessageType.Text'?MessageType.Text:MessageType.Media,
        mediaType: data['mediaType']=='MediaType.Audio'?MediaType.Audio:
        data['mediaType']=='MediaType.Video'?MediaType.Video:
        data['mediaType']=='MediaType.Photo'?MediaType.Photo:
            null
    );
  }

  static Map<String,dynamic> toJson(ReplyMessageModel model){
    return {
      'content':model.content,
      'replierId':model.replierId,
      'repliedToId':model.repliedToId,
      'type':model.type.toString(),
      'mediaType':model.mediaType.toString()
    };
  }

}