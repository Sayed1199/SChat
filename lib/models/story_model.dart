import 'package:firebase_auth/firebase_auth.dart';
import 'package:schat/models/user_model.dart';

class StoryModel{

  late String statusSender;
  String? mediaUrl;
  late int timeStamp;

  StoryModel({required this.statusSender,
    required this.mediaUrl,required this.timeStamp});


  factory StoryModel.fromJson(Map<String,dynamic> myMap){
    return StoryModel(
        statusSender: myMap['statusSender'],
        mediaUrl: myMap['mediaUrl'],
        timeStamp: myMap['timeStamp']
    );
  }

  static Map<String,dynamic> toJson(StoryModel model){
    return {
      'statusSender':model.statusSender,
      'mediaUrl':model.mediaUrl,
      'timeStamp':model.timeStamp
    };
  }


}