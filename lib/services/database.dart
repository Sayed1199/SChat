import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:schat/constants.dart';
import 'package:schat/controllers/auth_controller.dart';
import 'package:schat/models/media_model.dart';
import 'package:schat/models/message_model.dart';
import 'package:schat/models/story_model.dart';
import 'package:schat/models/user_model.dart';
import 'dart:math'as math;

import 'package:schat/widgets/chat_audio_bubble.dart';

class Database{

  final _fstore = FirebaseFirestore.instance;

  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection(USERS_COLLECTION);

  final CollectionReference _messagesCollection =
  FirebaseFirestore.instance.collection(MESSAGES_COLLECTION);


  Stream<QuerySnapshot> getContactsStream() {
    return _usersCollection.snapshots();
  }

  Stream<DocumentSnapshot> getUserContactsStream(String uid) {
    return _usersCollection.doc(uid).snapshots();
  }

  Future<DocumentSnapshot> getUser(String id) {
    return _usersCollection.doc(id).get();
  }

  Future<void> addUser(UserModel model)async{
    try{
      _usersCollection.doc(model.id).set(UserModel.userModelToJson(model),SetOptions(merge: true));
    }catch(e){
      print('Add User error: $e');
    }
  }

  Future<QuerySnapshot> getNewChats(
      String groupChatId, DocumentSnapshot lastSnapshot,
      [int limit = 20]) {
    try {
      return _messagesCollection
          .doc(groupChatId)
          .collection(CHATS_COLLECTION)
          .startAfterDocument(lastSnapshot)
          .limit(20)
          .orderBy('timeStamp', descending: true)
          .get();
    } catch (error) {
      print(
          '****************** DB getSnapshotsAfter error **********************');
      print(error);
      throw error;
    }
  }


  Future<QuerySnapshot> getChatItemData(String groupId, [int limit = 20]) {
    try {
      return _messagesCollection
          .doc(groupId)
          .collection(CHATS_COLLECTION)
          .orderBy('timeStamp', descending: true)
          .limit(limit)
          .get();
    } catch (error) {
      print(
          '****************** DB getChatItemData error **********************');
      throw error;
    }
  }

  Future<void> updateUserInfo(String userId, Map<String, dynamic> data) async {
    try {
      _usersCollection.doc(userId).set(data, SetOptions(merge: true));
    } catch (error) {
      print(
          '****************** DB updateUserInfo error **********************');
      print(error);
      throw error;
    }
  }

  void updateContacts(String userId, dynamic contacts) {
    try {
      _usersCollection
          .doc(userId)
          .set({'contacts': contacts}, SetOptions(merge: true));
    } catch (error) {
      print(
          '****************** DB updateContacts error **********************');
      print(error);
      throw error;
    }
  }


  void addNewMessage(String groupId, DateTime timeStamp, dynamic data) async{

    try {
      _messagesCollection
          .doc(groupId)
          .collection(CHATS_COLLECTION)
          .doc(timeStamp.millisecondsSinceEpoch.toString())
          .set(data,SetOptions(merge: true));
    } catch (error) {
      print('****************** DB addNewMessage error **********************');
      print(error);
      throw error;
    }
  }


  Future<void> addStory(StoryModel storyModel) async{

    try {
      await FirebaseFirestore.instance.collection('Stories')
          .doc(authController.firebaseUser.value!.uid).set({'sender':storyModel.statusSender},SetOptions(merge: true));
      await FirebaseFirestore.instance.collection('Stories')
          .doc(authController.firebaseUser.value!.uid)
          .collection("UserStories")
          .doc(storyModel.timeStamp.toString())
          .set(StoryModel.toJson(storyModel),SetOptions(merge: true));
    } catch (error) {
      print('****************** DB addNewMessage error **********************');
      print(error);
      throw error;
    }
  }


  Future<DocumentSnapshot> addToPeerContacts(
      String peerId, String newContact) async {
    DocumentReference doc;
    DocumentSnapshot docSnapshot;

    try {
      doc = _usersCollection.doc(peerId);
      docSnapshot = await doc.get();

      var peerContacts = [];

      docSnapshot.get('contacts').forEach((elem) => peerContacts.add(elem));
      peerContacts.add(newContact);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        final freshDoc = await transaction.get(doc);
        transaction.update(freshDoc.reference, {'contacts': peerContacts});
      });

       doc.set({'contacts': peerContacts}, SetOptions(merge: true));

      // doc.setData({'contacts': peerContacts}, merge: true);
    } catch (error) {
      print(
          '****************** DB addToPeerContacts error **********************');
      print(error);
      throw error;
    }

    return docSnapshot;
  }

  Stream<QuerySnapshot> getSnapshotsAfter(
      String groupChatId, DocumentSnapshot lastSnapshot) {
    try {
      return _messagesCollection
          .doc(groupChatId)
          .collection(CHATS_COLLECTION)
          .orderBy('timeStamp')
          .startAfterDocument(lastSnapshot)
          .snapshots();
    } catch (error) {
      print(
          '****************** DB getSnapshotsAfter error **********************');
      print(error);
      throw error;
    }
  }

  Stream<QuerySnapshot> getSnapshotsWithLimit(String groupChatId,
      [int limit = 10]) {
    try {
      return _messagesCollection
          .doc(groupChatId)
          .collection(CHATS_COLLECTION)
          .limit(limit)
          .orderBy('timeStamp', descending: true)
          .snapshots();
    } catch (error) {
      print(
          '****************** DB getSnapshotsWithLimit error **********************');
      print(error);
      throw error;
    }
  }

  void updateMessageField(dynamic snapshot, String field, dynamic value) {
    try {
      FirebaseFirestore.instance.runTransaction((transaction) async {
        // DocumentSnapshot freshDoc = await transaction.get(snapshot.reference);
        transaction.update(snapshot.reference, {'$field': value});
      });
    } catch (error) {
      print(
          '****************** DB updateMessageField error **********************');
      print(error);
      throw error;
    }
  }


  void addMediaUrl(String groupId, String url, MessageModel mediaMsg) {
    try {
      _messagesCollection
          .doc(groupId)
          .collection(MEDIA_COLLECTION)
          .doc(mediaMsg.timeStamp)
          .set(MediaModel.fromMsgToMap(mediaMsg),SetOptions(merge: true));
    } catch (error) {
      print('****************** DB addMediaUrl error **********************');
      print(error);
      throw error;
    }
  }

  Stream<QuerySnapshot> getMediaCount(String groupId) {
    try {
      return _messagesCollection
          .doc(groupId)
          .collection(MEDIA_COLLECTION)
          .snapshots();
    } catch (error) {
      print('****************** DB getMediaCount error **********************');
      print(error);
      throw error;
    }
  }

  Stream<QuerySnapshot> getChatMediaStream(String groupId) {
    try {
      return _messagesCollection
          .doc(groupId)
          .collection(MEDIA_COLLECTION)
          .snapshots();
    } catch (error) {
      print('****************** DB getChatMedia error **********************');
      print(error);
      throw error;
    }
  }


  Future<String?> getRandomID()async{

    AuthController authController = Get.put(AuthController());
    List<String>usersIDs = [];
    List<dynamic>userContacts=[];
    List<dynamic>peerContacts=[];

    DocumentSnapshot userSnapshot = await _fstore.collection(USERS_COLLECTION)
        .doc(authController.firebaseUser.value!.uid).get();

    Map<String,dynamic> mMAP = userSnapshot.data() as Map<String,dynamic>;

    if(mMAP['contacts'] != null){
      userContacts = userSnapshot.get('contacts');
    }

    QuerySnapshot querySnapshot = await _fstore.collection(USERS_COLLECTION).get();
    querySnapshot.docs.forEach((element) {
      if(!userContacts.contains(element.id) && element.id != authController.firebaseUser.value!.uid)
      usersIDs.add(element.id);
    });

    if(usersIDs.isNotEmpty){
      String id = usersIDs[math.Random().nextInt(usersIDs.length)];
      print('Random is is: ${id}');


      userContacts.add(id);
      _fstore.collection(USERS_COLLECTION)
          .doc(authController.firebaseUser.value!.uid).set({'contacts':userContacts},SetOptions(merge: true));

      ///////////////////////


      DocumentSnapshot peerSnapshot = await _fstore.collection(USERS_COLLECTION)
          .doc(id).get();

      Map<String,dynamic> peerMAP = peerSnapshot.data() as Map<String,dynamic>;

      if(peerMAP['contacts'] != null){
        peerContacts = peerSnapshot.get('contacts');
      }



      ///////////////////

      peerContacts.add(authController.firebaseUser.value!.uid);
      _fstore.collection(USERS_COLLECTION)
          .doc(id).set({'contacts':peerContacts},SetOptions(merge: true));

      return id;
    }else{
      return null;
    }

  }

  Future<void> deleteAMessage(String groupChatId,String timeStamp)async{

    await _messagesCollection.doc(groupChatId).collection(CHATS_COLLECTION).doc(timeStamp).delete();

  }


  Future<List<UserModel>?> getContactsAsUserModels()async{
    List<UserModel> usersList=[];
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(USERS_COLLECTION).doc(authController.firebaseUser.value!.uid).get();

    List<dynamic>? contactsList=(documentSnapshot.data() as Map<String,dynamic>)['contacts'];

    if(contactsList == null){
      print('null here');
      return [];
    }else{
      if(contactsList.isEmpty){
        print('empty here');
        return [];
      }else{

        for(String s in contactsList){
          usersList.add(UserModel.getUserModelFromJson(((await getUser(s)).data()) as Map<String,dynamic>));
          print('added contact ${s}');
        }
        print('added users: ${usersList}');
        return usersList;

      }
    }

  }

  Future<UserModel> getCurUserAsUserModel(String id)async{
    return UserModel.getUserModelFromJson
      (((await _usersCollection.doc(id).get()).data()) as Map<String,dynamic>);
  }



}