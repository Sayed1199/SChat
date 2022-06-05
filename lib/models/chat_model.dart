
import 'package:schat/models/message_model.dart';
import 'package:schat/models/user_model.dart';
import 'package:schat/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ChatModel{

  final Database db = Database();

  final String groupId;
  final String userId;
  final String peerId;
  final UserModel peer;
  final List<dynamic> messages;
  DocumentSnapshot? lastDoc;
  int? unreadCount;

  ChatModel({
    required this.groupId,
    required this.userId,
    required this.peerId,
    required this.peer,
    required this.messages,
    this.lastDoc,
    this.unreadCount
  });

  void setLastDoc(DocumentSnapshot doc) {
    lastDoc = doc;
  }

  void addMessage(MessageModel newMsg) {
    /*
    if (messages.length > 20) {
      messages.removeLast();
    }

    */
    messages.insert(0, newMsg);
  }

  Future<bool> fetchNewChats() async {
    final newData = await db.getNewChats(groupId, lastDoc!);
    await Future.delayed(Duration.zero).then((value) {
      newData.docs.forEach((element) {
        // print('new message added -------------> ${element['content']}');
        messages.add(MessageModel.fromJson(element.data()as Map<String,dynamic>));
      });

      if (newData.docs.isNotEmpty) {
        lastDoc = newData.docs[newData.docs.length - 1];
      }
    }).then((value) => value);

    return true;
  }

}






















