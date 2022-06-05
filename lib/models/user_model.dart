
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schat/constants.dart';

class UserModel{

  final String id;
  final String? username;
  String? email;
  String? phoneNumber;
  String? imageUrl;

  UserModel({required this.id,required this.username,this.email,this.phoneNumber,this.imageUrl});


  factory UserModel.getUserModelFromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username']==null?json['phoneNumber']:json['username'],
      email: json['email'],
      imageUrl: json['imageUrl']==null?anonPic:json['imageUrl'],
      phoneNumber: json['phoneNumber'],
    );
  }

  static Map<String,dynamic> userModelToJson(UserModel model){
    return {
      'id':model.id,
      'username':model.username,
      'email':model.email,
      'imageUrl':model.imageUrl,
      'phoneNumber':model.phoneNumber
    };
  }

}