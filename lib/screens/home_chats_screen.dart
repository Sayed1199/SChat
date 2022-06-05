import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:schat/constants.dart';
import 'package:schat/controllers/auth_controller.dart';
import 'package:schat/controllers/chats_list_controller.dart';
import 'package:schat/controllers/theme_controller.dart';
import 'package:schat/models/chat_model.dart';
import 'package:schat/models/message_model.dart';
import 'package:schat/screens/chat_item_screen.dart';
import 'package:schat/services/database.dart';
import 'package:schat/widgets/laoding_indicator.dart';

late ChatController chatController;

ThemeController themeController = Get.put(ThemeController());


class HomeChatWidgets extends StatefulWidget {
  const HomeChatWidgets({Key? key}) : super(key: key);

  @override
  State<HomeChatWidgets> createState() => _HomeChatWidgetsState();
}

class _HomeChatWidgetsState extends State<HomeChatWidgets> with AutomaticKeepAliveClientMixin{
  
  Database db = Database();
  AuthController authController = Get.put(AuthController());



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chatController = Get.put(ChatController());
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return authController.firebaseUser.value==null?Center(
      child: LoadingWidget(mColor: Colors.blue)
    ):StreamBuilder(
        stream: db.getUserContactsStream(authController.firebaseUser.value!.uid),
        builder: (context,snapshots){

          if(!snapshots.hasData){
            return Center(child: LoadingWidget(mColor: Colors.blue));
          }else{
            DocumentSnapshot documentSnapshot = snapshots.data as DocumentSnapshot;
            print('Data: ${documentSnapshot.data()}');
            print('Chats: ${chatController.chats.value.length}');
            print('Contacts: ${chatController.contacts.value.length}');
            return Column(
              children: [
                SizedBox(height: 10,),
                BodyWidget(),
              ],
            );


          }

        });

  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class ChatListItem extends StatefulWidget {

  final ChatModel chatData;

  const ChatListItem({Key? key,required this.chatData}) : super(key: key);

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {

  late Stream<QuerySnapshot> _stream;
  late Database db;
  List<dynamic> unreadMessages = [];


  String getDate() {
    DateTime date = DateTime.now();
    return DateFormat.yMd(date).toString();
  }

  String formatTime(MessageModel message) {
    int hour = message.sendDate.hour;
    int min = message.sendDate.minute;
    String hRes = hour <= 9 ? '0$hour' : hour.toString();
    String mRes = min <= 9 ? '0$min' : min.toString();
    return '$hRes:$mRes';
  }



  void _addNewMessages(MessageModel newMsg) {

    if (widget.chatData.messages.isEmpty ||
        newMsg.sendDate.isAfter(widget.chatData.messages[0].sendDate)) {
      widget.chatData.addMessage(newMsg);

      if (newMsg.fromId != widget.chatData.userId) {
        print('playing sound');
        widget.chatData.unreadCount = widget.chatData.unreadCount!+1;

        // play notification sound
        /*
        if(widget.chatData.messages.isNotEmpty && widget.chatData.messages[0].sendDate != newMsg.sendDate)
         if(Platform.isIOS)
          Utils.playSound('assets/mp3/notification_sound.mp3');
        else Utils.playSound('assets/mp3/notification_sound.mp3');
        */

        WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
          chatController.bringChatToTop(widget.chatData.groupId);
          setState(() {});
        });
      }
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    db = Database();
    _stream = db.getSnapshotsWithLimit(widget.chatData.groupId, 1);
    widget.chatData.unreadCount=0;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      key: UniqueKey(),
      color: Colors.transparent,
      child: InkWell(
        // splashColor: Colors.transparent,
        highlightColor: kBlackColor2,
        onTap: (){
          print('Going to chatPage');
          print('GroupID: ${widget.chatData.groupId}');
          print('chatData peer: ${widget.chatData.peerId}');
          print('image peer: ${widget.chatData.peer.imageUrl}');
          Get.to(()=>ChatItemScreen(chatData: widget.chatData));
        },
        child: Container(
          color: Colors.transparent,
          height: 80,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(widget.chatData.peer.imageUrl!),
            ),

            title: Obx(()=>
              Text(widget.chatData.peer.username!, style: GoogleFonts.lato(
                  fontSize: 18,
                  color: themeController.isDarkModeEnabled.value==true?Colors.white:Colors.black)
              ),
            ),

            subtitle: _PreviewText(
              stream: _stream,
              onNewMessageRecieved: _addNewMessages,
              peerId: widget.chatData.peerId,
              userId: widget.chatData.userId,
            ),
            trailing: _UnreadCount(
              unreadCount: widget.chatData.unreadCount==null?0:widget.chatData.unreadCount!,
              lastMessage:  widget.chatData.messages.isNotEmpty?widget.chatData.messages[0]:null,
            ),

          ),
        ),
      ),
    );
  }
}

class BodyWidget extends StatelessWidget {

  const BodyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Obx(()=>
        chatController.isLoading.value==false? chatController.chats.value.isNotEmpty? Padding(
          padding: const EdgeInsets.only(left: 8.0,top: 2),
          child: chatController!=null? ListView.separated(
            itemCount: chatController.chats.value.length,
            itemBuilder: (context,index){
              print("ChatItem: user: ${chatController.chats.value[index].userId}");
              print("ChatItem: peer: ${chatController.chats.value[index].peerId}");
              return ChatListItem(chatData:chatController.chats.value[index]);
            },
            separatorBuilder: (xontext,index){
              return Divider(indent: 85,
                endIndent: 15,
                height: 0,
                thickness: 1,
                color: kBlackColor3,);
            },
          ):Center(
            child:LoadingWidget(mColor: Colors.blue,),
        ),
        ):Center(child: Text('No Chats yet',style: GoogleFonts.lato(fontSize: 20,fontWeight: FontWeight.w500),))
            :Center(child: LoadingWidget(mColor: Colors.blue)),
        ),
      ),
    );
  }
}


class _UnreadCount extends StatelessWidget {
  const _UnreadCount({
    Key? key,
    required this.unreadCount,
    required this.lastMessage,
  }) : super(key: key);

  final int unreadCount;
  final MessageModel? lastMessage;

  String formatTime(MessageModel message) {
    int hour = message.sendDate.hour;
    int min = message.sendDate.minute;
    String hRes = hour <= 9 ? '0$hour' : hour.toString();
    String mRes = min <= 9 ? '0$min' : min.toString();
    return '$hRes:$mRes';
  }

  @override
  Widget build(BuildContext context) {
    print('myunredCount: ${unreadCount}');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (lastMessage != null)
          lastMessage != null? Obx(()=>
             Text(formatTime(lastMessage!),
                style: GoogleFonts.lato(
                    color: themeController.isDarkModeEnabled.value==true?Colors.white.withOpacity(0.8)
                        :Colors.black.withOpacity(0.8),
                    fontSize: 14
                ),
            ),
          ):
          Container(height: 0,width: 0,),
          SizedBox(height: 5),
        unreadCount != null && unreadCount > 0 ?
        Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.blue,
            ),
            child: Center(
              child: Obx(()=>
                Text(
                  '$unreadCount',
                  style: TextStyle(
                    color: themeController.isDarkModeEnabled.value==true?Colors.white.withOpacity(0.8)
                        :Colors.black.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ):Container(width: 0,height: 0,),

      ],
    );
  }
}

class _PreviewText extends StatelessWidget {
  const _PreviewText({
    Key? key,
    required this.stream,
    required this.peerId,
    required this.userId,
    required this.onNewMessageRecieved,
  }) : super(key: key);

  final Stream<QuerySnapshot> stream;
  final String peerId;
  final String userId;
  final Function onNewMessageRecieved;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (ctx, AsyncSnapshot<QuerySnapshot>snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting)
          return Container(height: 0, width: 0);
        else {
          QuerySnapshot? querySnapshot = snapshots.data;
          if(querySnapshot != null){

            if (querySnapshot.docs.isNotEmpty) {
              final mSnapShot = querySnapshot.docs[0];
              MessageModel newMsg = MessageModel.fromJson(mSnapShot.data() as Map<String,dynamic>);
              onNewMessageRecieved(newMsg);
              return Row(
                children: [
                  newMsg.type == MessageType.Media
                      ? Container(
                    child: Row(
                      children: [
                        Obx(()=>
                          Icon(
                            newMsg.mediaType == MediaType.Photo
                                ? Icons.photo_camera
                                :newMsg.mediaType == MediaType.Audio?
                                Icons.audiotrack
                                : Icons.videocam,
                            size:
                            newMsg.mediaType == MediaType.Photo ? 15 : 20,
                            color: themeController.isDarkModeEnabled.value==true?Colors.white.withOpacity(0.45):
                            Colors.black54.withOpacity(0.45),
                          ),
                        ),
                        SizedBox(width: 8),
                        Obx(()=>
                           Text(
                              newMsg.mediaType == MediaType.Photo
                                  ? 'Photo'
                                  : newMsg.mediaType==MediaType.Audio?'Audio'
                                  :'Video',
                              style: GoogleFonts.lato(
                                  color: themeController.isDarkModeEnabled.value==true?Colors.white.withOpacity(0.8)
                                      :Colors.black.withOpacity(0.8),
                                fontSize: 14

                              )),
                        )
                      ],
                    ),
                  )
                      : Flexible(
                    child: Obx(()=>
                      Text(newMsg.content,
                          style: GoogleFonts.lato(
                            color: themeController.isDarkModeEnabled.value==true?Colors.white.withOpacity(0.8)
                                :Colors.black.withOpacity(0.8),
                            fontSize: 14
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  if (newMsg.fromId != peerId) ...[
                    SizedBox(width: 5),
                       Icon(
                        Icons.done_all,
                        size: 19,
                        color: newMsg.isSeen
                            ? Colors.blue
                            : themeController.isDarkModeEnabled.value==false? Colors.black.withOpacity(0.5):Colors.white.withOpacity(0.5),
                      ),

                  ],
                ],
              );
            } else
              return Container(height: 0, width: 0);
          }else{
            return Container(width: 0,height: 0,);
          }

        }
      },
    );
  }
}
