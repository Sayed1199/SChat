import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:schat/constants.dart';
import 'package:schat/controllers/auth_controller.dart';
import 'package:schat/models/chat_model.dart';
import 'package:schat/models/message_model.dart';
import 'package:schat/models/user_model.dart';
import 'package:schat/services/database.dart';

class ChatController extends GetxController{
  AuthController authController = Get.put(AuthController());
  var isLoading = Rx<bool>(true);
  final db = Database();

  late User? _user;
  late UserModel _userDetails;
  late String _userId;
  var contacts = Rx<List<String>>([]);
  var chats = Rx<List<ChatModel>>([]);
  @override
  void onReady() async{
    // TODO: implement onReady
    super.onReady();

    await getUserDetailsAndContacts();
    await fetchChats();



  }

  String getGroupId(String contact) {
    String groupId;
    if (_userId.hashCode <= contact.hashCode)
      groupId = '$_userId-$contact';
    else
      groupId = '$contact-$_userId';

    return groupId;
  }

  Future<dynamic> getUserDetailsAndContacts()async {
    _user = authController.firebaseUser.value;
    _userId = _user!.uid;
    DocumentSnapshot userData = await db.getUser(_userId);
    Map<String,dynamic> data = userData.data()as Map<String,dynamic>;
    _userDetails =
        UserModel.getUserModelFromJson(data);

    if (data['contacts'] != null) {

        userData.get('contacts').forEach((elem) {
          contacts.value.add(elem);
        });
    }
    print('fetched Contacts: ${contacts.value}');
    isLoading.value == false;
  }

  Future<ChatModel> getChatModel(String peerId)async{
    String groupId = getGroupId(peerId);
    final peer = await db.getUser(peerId);
    final UserModel person = UserModel.getUserModelFromJson(peer.data() as Map<String,dynamic>);
    QuerySnapshot messagesData = await db.getChatItemData(groupId);

    int unreadCount = 0;
    List<MessageModel> messages = [];
    for (int i = 0; i < messagesData.docs.length; i++) {
      var tmp = MessageModel.fromJson(messagesData.docs[i].data() as Map<String, dynamic>);
      messages.add(tmp);
      if(tmp.fromId == peerId && !tmp.isSeen) unreadCount++;
    }

    var lastDoc;
    if (messagesData.docs.isNotEmpty)
      lastDoc = messagesData.docs[messagesData.docs.length - 1];

    ChatModel chatData = ChatModel(
      userId: _userDetails.id,
      peerId: person.id,
      groupId: groupId,
      peer: person,
      messages: messages,
      lastDoc: lastDoc,
      unreadCount: unreadCount,
    );
    return chatData;

  }

  Future<bool> fetchChats() async {
    print('Started fetching Chats:}');

    chats.value.clear();
    Future.forEach(contacts.value, (contact) async {
      final chatData = await getChatModel(contact.toString());
      chats.value.add(chatData);
    }).then((value) {
      isLoading.value = false;
      print('fetched Chats: ${chats.value}');
    });
    return true;
  }


  void bringChatToTop(String groupId) {
    if (chats.value.isNotEmpty && chats.value[0].groupId != groupId) {
      // bring latest interacted contact and chat to top
      var ids = groupId.split('-');
      var peerId = ids.firstWhere((element) => element != _user!.uid);

      var cIndex = contacts.value.indexWhere((element) => element == peerId);
      contacts.value.removeAt(cIndex);
      contacts.value.insert(0, peerId);

      print('bring chat To Top: ${contacts.value}');

      db.updateUserInfo(_user!.uid, {'contacts': contacts});

      var index = chats.value.indexWhere((element) => element.groupId == groupId);
      var temp = chats.value[index];
      chats.value.removeAt(index);
      chats.value.insert(0, temp);

      //isLoading.value=false;

    }
  }


  void addToInitChats(ChatModel chatData) {
    if (chats.value.contains(chatData)) return;
    chats.value.insert(0, chatData);

  }

  void addMessageToInitChats(ChatModel chatRoom, MessageModel msg) {
    chats.value
        .firstWhere((element) => element.peer.id == chatRoom.peer.id)
        .messages
        .insert(0, msg);
  }

  void addToContacts(String uid) {
    contacts.value.add(uid);
  }

  void handleMessagesNotFromContacts(List<dynamic> newContacts) async {
    if (newContacts.length > contacts.value.length) {
      for (int i = contacts.value.length; i < newContacts.length; ++i) {
        final chatData = await getChatModel(newContacts[i]);
        chats.value.insert(0, chatData);
        contacts.value.insert(0, newContacts[i]);
      }
      db.updateContacts(_userDetails.id, contacts);
    }
  }

  void clearChatsAndContacts() {
    chats.value.clear();
    contacts.value.clear();
  }



}