import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schat/constants.dart';
import 'package:schat/controllers/auth_controller.dart';
import 'package:schat/controllers/chats_list_controller.dart';
import 'package:schat/controllers/record_controller.dart';
import 'package:schat/controllers/theme_controller.dart';
import 'package:schat/models/chat_model.dart';
import 'package:schat/models/message_model.dart';
import 'package:schat/models/reply_message_model.dart';
import 'package:schat/models/user_model.dart';
import 'package:schat/screens/home.dart';
import 'package:schat/screens/record_screen.dart';
import 'package:schat/services/database.dart';
import 'package:schat/utils/utils.dart';
import 'package:schat/widgets/chat_audio_bubble.dart';
import 'package:schat/widgets/chat_bubble.dart';
import 'package:schat/widgets/chat_item_app_bar.dart';
import 'package:schat/widgets/media_uploading_bubble.dart';
import 'package:schat/widgets/replying_bot_container.dart';
import 'package:schat/widgets/selected_media_preview.dart';
import 'package:share_plus/share_plus.dart';

enum LoaderStatus {
  STABLE,
  LOADING,
}

ThemeController themeController = Get.put(ThemeController());
RecordController recordController = Get.put(RecordController());
AuthController authController = Get.put(AuthController());

class ChatItemScreen extends StatefulWidget {

  final ChatModel chatData;

  const ChatItemScreen({Key? key,required this.chatData}) : super(key: key);

  @override
  State<ChatItemScreen> createState() => _ChatItemScreenState();
}

class _ChatItemScreenState extends State<ChatItemScreen> with AutomaticKeepAliveClientMixin{

  late Database db;
  DocumentSnapshot? lastSnapshot;

  late TextEditingController _textEditingController;
  late ScrollController _scrollController;
  late FocusNode _textFieldFocusNode;

  late String userId;
  late String peerId;
  late String groupChatId;

  File? _selectedMedia;
  MediaType? pickedMediaType;
  bool _mediaSelected = false;
  final picker = ImagePicker();
  MessageModel? mediaMsg;

  late StreamSubscription<bool> keyboardSubscription;
  var keyboardVisibilityController = KeyboardVisibilityController();


  bool isVisible = false;
  bool scrolledAbove = false;

  bool _isFetchingNewChats = false;
  GlobalKey textFieldKey = GlobalKey();
  MessageModel? msgToReply;
  bool replied = false;

  late FocusNode bodyFocusNode;

  ChatController chatController = Get.put(ChatController());


  late CancelableOperation paginateOperation;
  LoaderStatus loaderStatus = LoaderStatus.STABLE;



  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    // description
    importance: Importance.high,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    db = Database();
    _textEditingController = TextEditingController();
    _scrollController = ScrollController();
    _textFieldFocusNode = FocusNode();
    bodyFocusNode = FocusNode();

    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        isVisible=visible;
      });
    });

    userId = widget.chatData.userId;
    peerId = widget.chatData.peerId;
    groupChatId = widget.chatData.groupId;

    widget.chatData.unreadCount!=0;


    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardSubscription.cancel();
    _textEditingController.dispose();
    _scrollController.removeListener(() {});
    _scrollController.dispose();
    _textFieldFocusNode.dispose();
    bodyFocusNode.dispose();
    super.dispose();
  }

  ///////////////////

  void onMessageSend(String content, MessageType type,
      {MediaType? mediaType, ReplyMessageModel? replyDetails}) async {
    // clear text field
    if (content != '') _textEditingController.clear();
    // create timestamp
    DateTime time = DateTime.now();
    final newMessage = MessageModel(
      content: content,
      fromId: userId,
      toId: peerId,
      sendDate: time,
      timeStamp: time.millisecondsSinceEpoch.toString(),
      isSeen: false,
      type: type,
      mediaType: mediaType,
      mediaUrl: null,
      uploadFinished: false,
      reply: replyDetails,
    );

    /////////////////////////////

    //notifications hereee for me ....

    flutterLocalNotificationsPlugin.show(0,
        authController.firebaseUser.value?.displayName,
        content,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            color: Colors.blue,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            //icon: "@mipmap/ic_launcher",
          ),
        ),
    );


    /////////////////////////////


    // add message to messages list
    widget.chatData.messages.insert(0, newMessage);

    // set media message
    if (type == MessageType.Media) mediaMsg = newMessage;

    // add message to database only if its text message
    // media message should be added after uploading and getting its media url
    if (type == MessageType.Text) {
      db.addNewMessage(
        groupChatId,
        time,
        MessageModel.toJson(newMessage),
      );
      print('adding text');
    }

    final userContacts = await chatController.contacts.value;
    // add user to contacts if not already in contacts
    print('Contacts: $userContacts');
    if (!userContacts.contains(peerId)) {
      chatController.addToContacts(peerId);
      db.updateContacts(userId, userContacts);

      // add to peer contacts too
      var userRef = await db.addToPeerContacts(peerId, userId);

      UserModel person = UserModel.getUserModelFromJson(userRef.data() as Map<String,dynamic>);
      ChatModel initChatData = ChatModel(
        userId: userId,
        peerId: peerId,
        groupId: groupChatId,
        peer: person,
        messages: [newMessage],
      );
      chatController.addToInitChats(initChatData);
    } else {
      chatController.bringChatToTop(groupChatId);
    }
  }

  void _onUploadFinished(String url) {
    if (mediaMsg != null) {
      var msg = widget.chatData.messages.firstWhere(
            (elem) => elem.sendDate == mediaMsg!.sendDate,
      );

      //
      if (msg != null) {
        msg.mediaUrl = url;
        msg.uploadFinished = true;

        final time = DateTime.now();

        // add message to database after grabbing it's media url
        db.addNewMessage(
          groupChatId,
          time,
          MessageModel.toJson(msg),
        );
        print('adding media');
        //db.addMediaUrl(groupChatId, url, mediaMsg!);
      }
    }
  }

  void onReplied(MessageModel msg) async {
    _textFieldFocusNode.requestFocus();
    msgToReply = msg;
    replied = true;
    // if (isVisible) {
    // update input field state to show reply preview
    textFieldKey.currentState!.setState(() {});
    // }
  }

  void onSend(String msgContent,
      {MessageType? type, MediaType? mediaType, ReplyMessageModel? replyDetails}) {
    // if not media is not selected add new message as text message

    print('on msg send');

    if (type == MessageType.Text) {
      if (msgContent.isEmpty) return;
      _textEditingController.clear();
      recordController.isRecordIconEnabled.value=true;
      _scrollController.animateTo(_scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.easeIn);
      // send new message
      onMessageSend(msgContent, MessageType.Text, replyDetails: replyDetails);
    } else {

        if (msgContent
            .trim()
            .isEmpty) msgContent = '';
        onMessageSend(msgContent, MessageType.Media,
            mediaType: mediaType, replyDetails: replyDetails);
        setState(() {
          _mediaSelected = false;
        });
      }

    // remove reply preview after send if the message is replied
    if (replyDetails != null) {
      replied = false;
      msgToReply = null;
    }
    FocusScope.of(context).requestFocus(_textFieldFocusNode);
  }

  Stream<QuerySnapshot> stream() {

    
    var snapshots;
    if (lastSnapshot != null) {
      // lastSnapshot is set as the last message recieved or sent
      // if it is set(users interacted) fetch only messages added after this message
      snapshots = db.getSnapshotsAfter(groupChatId, lastSnapshot!);
    } else {
      // otherwise fetch a limited number of messages(10)
      snapshots = db.getSnapshotsWithLimit(groupChatId, 10);
    }
    return snapshots;
    


  }

  void handleSeenStatusUpdateWhenFromPeer() {
    int index = -1;
    for (int i = 0; i < widget.chatData.messages.length; i++) {
      final item = widget.chatData.messages[i];
      if (i == widget.chatData.messages.length - 1) {
        index = i;
        break;
      } else {
        if (item.fromId == userId && item.isSeen) {
          index = i;
          break;
        }
      }
    }
    if (index != -1)
      for (int i = index; i >= 0; i--)
        widget.chatData.messages[i].isSeen = true;
  }

  void handleSeenStatusWhenFromMe(MessageModel newMsg) {
    int index = -1;
    for (int i = 0; i < widget.chatData.messages.length; i++) {
      if (i == widget.chatData.messages.length - 1) {
        index = i;
        break;
      } else {
        if (widget.chatData.messages[i].fromId == userId &&
            widget.chatData.messages[i].isSeen) {
          index = i;
          break;
        }
      }
    }
    if (index != -1) {
      bool s =
      newMsg.sendDate.isAfter(widget.chatData.messages[index].sendDate);

      if (s && newMsg.isSeen)
        for (int i = index; i >= 0; i--)
          if (widget.chatData.messages[i].fromId == userId)
            widget.chatData.messages[i].isSeen = true;
    }
  }

  Future<void> createNotification(String header,String body) async {



  }



  void addNewMessages(AsyncSnapshot<QuerySnapshot> snapshots)async{


    if (snapshots.hasData) {
      QuerySnapshot? querySnapshot = snapshots.data;

        int length = querySnapshot!.size;
        if (length != 0) {
          // set lastSnapshot to last message fetched to later use
          // for fetching new messages only after this snapshot
          lastSnapshot = querySnapshot.docs[length - 1];
        }

      snapshots.data!.docs.map((value)async {
        /////////////////////////

        MessageModel newMsg = MessageModel.fromJson(
            value.data() as Map<String, dynamic>);

        if (widget.chatData.messages.isNotEmpty) {
          // add message to the list only if it's after the first item in the list
          if (newMsg.sendDate.isAfter(widget.chatData.messages[0].sendDate)) {
            widget.chatData.messages.insert(0, newMsg);

            // // play notification sound
            // Utils.playSound('mp3/newMessage.mp3');

            // if message is from peer update seen status of all unseen messages

            //////////////////////


            flutterLocalNotificationsPlugin.show(0,
              'peer',
              newMsg.content,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  color: Colors.blue,
                  // TODO add a proper drawable resource to android, for now using
                  //      one that already exists in example app.
                  //icon: "@mipmap/ic_launcher",
                ),
              ),
            );


            /////////////////////

            if (newMsg.fromId == peerId) {
              handleSeenStatusUpdateWhenFromPeer();
            }
          } else {
            // if new snapshot is a message from this user, find the last seen message index
            if (newMsg.fromId == userId && newMsg.isSeen) {
              handleSeenStatusWhenFromMe(newMsg);
            }
          }
        }

      }).toList();


        ///////////////////////////////////////////

    }

  }

  Future pickImage() async {
    var pickedFile = await Utils.pickImage(context);
    if (pickedFile != null) {
      setState(() {
        pickedMediaType = MediaType.Photo;
        _selectedMedia = File(pickedFile.path);
        _mediaSelected = true;
      });
    }else{
    }
  }

  Future pickVideo() async {
    var pickedFile = await Utils.pickVideo(context);
    if (pickedFile != null) {
      setState(() {
        pickedMediaType = MediaType.Video;
        _selectedMedia = File(pickedFile.path);
        _mediaSelected = true;
      });
    }
  }

  /////////////////////////////

  Widget _buildTextInputField() {
    return StatefulBuilder(
      key: textFieldKey,
      builder: (ctx, thisState) {
        bool reply = false;
        MessageModel? repliedMessage;

        // update state when message is being replied
        reply = replied;
        repliedMessage = msgToReply != null? msgToReply : null;
        thisState(() {
        });

        void send() {

          print('sending');

          ReplyMessageModel replyDetails;
          if (repliedMessage != null) {
            replyDetails = ReplyMessageModel(
                content: repliedMessage!.type == MessageType.Text
                    ? repliedMessage!.content
                    :
                repliedMessage!.mediaUrl!,
                replierId: userId,
                repliedToId: repliedMessage!.fromId,
                type: repliedMessage!.type,
                mediaType: repliedMessage!.mediaType);
            onSend(_textEditingController.text,
                type: MessageType.Text, replyDetails: replyDetails);

            // reset state
            reply = false;
            repliedMessage = null;
            thisState(() {

            });
          }else{
            onSend(_textEditingController.text,
                type: MessageType.Text, replyDetails: null);
            print('hiii');
            thisState(() {
              reply=false;
              repliedMessage=null;
            });

          }
        }

        Widget _buildTextField() {
          return Flexible(
            child: Container(
              padding: const EdgeInsets.only(left: 8, right: 5),
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(25)),
              child: TextField(
                maxLines: null,
                style: TextStyle(
                    fontSize: 16, color: Colors.white.withOpacity(0.95)),
                focusNode: _textFieldFocusNode,
                controller: _textEditingController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.go,
                cursorColor: Colors.blue[800],
                keyboardAppearance: Brightness.dark,
                onChanged: (value){
                  print('value: $value');
                  if(value != ''){
                    recordController.isRecordIconEnabled.value=false;
                  }else{
                    recordController.isRecordIconEnabled.value=true;
                  }
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type smth....',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                onSubmitted: (_) {
                  send();
                },
              ),
            ),
          );
        }

        Widget _buildReplyMessage() {

          return AnimatedContainer(
            padding: const EdgeInsets.only(left: 20),
            duration: Duration(milliseconds: 200),
            height: reply ? 70 : 0,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                top: reply
                    ? BorderSide(color: kBorderColor3)
                    : BorderSide(color: Colors.transparent),
              ),
            ),
            child: replied
                ? ReplyMessagePreview(
              onCanceled: () {
                print('Canceling1');
                thisState(() {
                  replied = false;
                  repliedMessage = null;
                  reply = false;
                  msgToReply = null;
                });
              },
              repliedMessage: repliedMessage!,
              peerName: widget.chatData.peer.username!,
              reply: reply,
              userId: userId,
            )
                : Container(width: 0, height: 0),
          );
        }

        return Container(
          decoration: BoxDecoration(
            // color: kBlackColor2,
            // border: Border.all(color: kBorderColor3),
            borderRadius: reply
                ? BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            )
                : BorderRadius.circular(25),
          ),
          // borderRadius: BorderRadius.circular(25)),
          child: Column(
            children: [
              _buildReplyMessage(),
              Container(
                margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // SizedBox(width: 5),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: Icon(
                          CupertinoIcons.photo,
                          size: 25,
                          color: Colors.blue[500],
                        ),
                        onPressed: () => pickImage(),
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      child: Icon(
                        CupertinoIcons.camera,
                        size: 25,
                        color: Colors.blue[500],
                      ),
                      onPressed: () => pickVideo(),
                    ),
                    _buildTextField(),
                    // Spacer(),
                    Obx(()=>
                        CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: Container(
                          padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue[800]
                            ),
                          child: Icon(recordController.isRecordIconEnabled.value==false?
                          Icons.send_sharp:CupertinoIcons.mic,
                              size: 25, color: Colors.white),
                        ),
                        onPressed: recordController.isRecordIconEnabled.value==false?send:recordAudio,
                      ),
                    ),
                    SizedBox(width: 0),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ///////////////////////////////

  bool _onNotification(Notification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels >=
          notification.metrics.maxScrollExtent - 40) {
        if (loaderStatus != null && loaderStatus == LoaderStatus.STABLE) {
          loaderStatus = LoaderStatus.LOADING;
          paginateOperation = CancelableOperation.fromFuture(
              widget.chatData.fetchNewChats().then(
                    (_) {
                  loaderStatus = LoaderStatus.STABLE;
                  setState(() {
                    _isFetchingNewChats = false;
                  });
                },
              ));
        }
      }
    }
    return true;
  }

  @override
  void didUpdateWidget(covariant ChatItemScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: WillPopScope(
        onWillPop: ()async{
          widget.chatData.unreadCount=0;
          print('unreadCount: ${widget.chatData.unreadCount}');
          Get.offAll(()=>HomeScreen());
          return true;
        },
        child: Scaffold(
          // resizeToAvoidBottomInset: false,
          appBar: PreferredSize(
            preferredSize: _mediaSelected
                ? Size.fromHeight(0)
                : Size.fromHeight(kToolbarHeight),
            child: ChatItemAppbar(widget.chatData.peer, widget.chatData.groupId),
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(bodyFocusNode);
            },
            child: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  StreamBuilder<QuerySnapshot>(
                  stream: stream(),
              builder: (ctx,snapshots) {
                addNewMessages(snapshots);
                return LayoutBuilder(
                  builder: (ctx, constraints) {
                    return Column(
                      children: [
                        Flexible(
                          child: _Messages(
                            scrollController: _scrollController,
                            chatData: widget.chatData,
                            onNotification: _onNotification,
                            selectedMedia: _selectedMedia!= null?_selectedMedia:null,
                            onReplied: onReplied,
                            onUploadFinished: _onUploadFinished,
                          ),
                        ),
                        _buildTextInputField(),
                      ],
                    );
                  },
                );
              },
            ),
                  Positioned(
                    right: 0,
                    bottom: 150,
                    child: _ToBottom(controller: _scrollController),
                  ),
                  if (_mediaSelected)
                    SelectedMediaPreview(
                      file: _selectedMedia!,
                      onClosed: () {
                        print('closing media');
                        setState(() => _mediaSelected = false);
                        },
                      onSend: onSend,
                      textEditingController: _textEditingController,
                      pickedMediaType: pickedMediaType!,
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  recordAudio() {

    Get.to(()=>RecordScreen(onSaved: (){
      print('saved');
    },chatData: widget.chatData,time: DateTime.now(),));


  }


}

class _ToBottom extends StatefulWidget {
  final ScrollController controller;
  const _ToBottom({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  __ToBottomState createState() => __ToBottomState();
}

class __ToBottomState extends State<_ToBottom> {
  bool reachedThereshold = false;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      if (widget.controller.position.pixels >= 600) {
        if (!reachedThereshold) {
          setState(() {
            reachedThereshold = true;
          });
        }
      }
      if (widget.controller.position.pixels < 600) {
        if (reachedThereshold) {
          setState(() {
            reachedThereshold = false;
          });
        }
      }
    });
  }

  void onTap() {
    widget.controller.animateTo(widget.controller.position.minScrollExtent,
        duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  Widget _buildIcon() {
    return Container(
      width: 70,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: CupertinoButton(
        color: Colors.transparent,
        padding: const EdgeInsets.all(0),
        onPressed: onTap,
        child: Container(
          child: Icon(Icons.arrow_downward,
              size: 30, color: Colors.blue),
          // padding: const EdgeInsets.all(3),
          /*
            decoration: BoxDecoration(
              border:
              Border.all(color: Colors.teal, width: 1.5),
              borderRadius: BorderRadius.circular(20)),
          */
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return reachedThereshold ? _buildIcon() : Container(height: 0, width: 0);
  }
}

class _Messages extends StatelessWidget {
  final ScrollController scrollController;
  final ChatModel chatData;
  final bool Function(Notification)? onNotification;
  final File? selectedMedia;
  final Function onUploadFinished;
  final Function onReplied;

  const _Messages({
    Key? key,
    required ScrollController scrollController,
    required this.chatData,
    required this.onNotification,
    required this.selectedMedia,
    required this.onUploadFinished,
    required this.onReplied,
  })  : scrollController = scrollController,
        super(key: key);

  Widget _buildMessageItem(MessageModel message, bool withoutAvatar, bool last,
      bool first, bool isMiddle) {
    if (message.type == MessageType.Media) {
      if (message.mediaUrl == null || !message.uploadFinished!){

        if(message.mediaType == MediaType.Audio){

          print('mediaBubble started');

          return AudioBubble(message: message, onReplied: onReplied,avatarImageUrl: chatData.peer.imageUrl!,);


        }else {
          return MediaUploadingBubble(
            groupId: chatData.groupId,
            file: selectedMedia,
            time: message.sendDate,
            onUploadFinished: onUploadFinished,
            message: message,
            mediaType: message.mediaType!,
          );
        }
    }
      else
        return ChatBubble(
          message: message,
          isMe: message.fromId == chatData.userId,
          peer: chatData.peer,
          withoutAvatar: withoutAvatar,
          onReply: onReplied,
        );
    }
    return ChatBubble(
      message: message,
      isMe: message.fromId == chatData.userId,
      peer: chatData.peer,
      withoutAvatar: withoutAvatar,
      onReply: onReplied,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: onNotification,
      child: ListView.separated(
        addAutomaticKeepAlives: true,
        physics: const AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        reverse: true,
        padding:
        const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        itemCount: chatData.messages.length,
        itemBuilder: (ctx, i) {
          int length = chatData.messages.length;
          return GestureDetector(
            onLongPress: (){
              print('long Press ${i}');
              showMessageOptions(context,chatData.messages[i]);
            },
            child: _buildMessageItem(
                chatData.messages[i],
                ChatOps.withoutAvatar(
                    i, length, chatData.messages, chatData.peerId),
                ChatOps.isLast(i, length, chatData.messages),
                ChatOps.isFirst(i, length, chatData.messages),
                ChatOps.isMiddle(i, length, chatData.messages)),
          );
        },
        separatorBuilder: (_, i) {
          final msgs = chatData.messages;
          int length = msgs.length;
          if ((i != length && msgs[i].fromId != msgs[i + 1].fromId) ||
              msgs[i].reply != null) return SizedBox(height: 15);
          return SizedBox(height: 5);
        },
      ),
    );
  }

  void deleteAMessage(MessageModel msg)async{

    Database db = Database();

    chatData.messages.removeAt(chatData.messages.indexOf(msg));
     db.deleteAMessage(chatData.groupId, msg.timeStamp);



  }

  void showMessageOptions(BuildContext context,MessageModel msg){
    showModalBottomSheet(context: context, builder: (ctx){
      return Obx(()=>
         AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.bounceInOut,
          height: 120,
          decoration: BoxDecoration(
            color: themeController.isDarkModeEnabled.value==true?
            Colors.white:Colors.black,
            shape: BoxShape.rectangle,
          ),
           child: Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [

                 GestureDetector(
                   onTap: (){
                     print('deleting');
                     shareAMessage(msg);
                     Get.back();
                   },
                   child:  Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                       Icon(Icons.share,color: Colors.blue,size: 30,),
                       SizedBox(width: 5,),
                       Obx(()=>
                          Text('Share',style: GoogleFonts.lato(
                           color: themeController.isDarkModeEnabled.value==true?
                           Colors.black:Colors.white,
                           fontSize: 22,
                         ),),
                       ),
                     ],
                   ),
                 ),

                 Obx(()=> Divider(color: themeController.isDarkModeEnabled.value==true?Colors.white: Colors.black,thickness: 3,)),
                 SizedBox(height: 10,),

                 GestureDetector(
                   onTap: (){
                     print('deleting');
                     deleteAMessage(msg);
                     Get.back();
                   },
                   child:  Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                       Icon(CupertinoIcons.delete,color: Colors.blue,size: 30,),
                       SizedBox(width: 5,),
                       Obx(()=>
                          Text('Delete',style: GoogleFonts.lato(
                           color: themeController.isDarkModeEnabled.value==true?
                           Colors.black:Colors.white,
                           fontSize: 22,
                         ),),
                       ),
                     ],
                   ),
                 ),




               ],
             ),
           ),
         ),
      );
    });
  }

  void shareAMessage(MessageModel msg) {

    if(msg.type == MessageType.Text){
      Share.share(msg.content);
    }else{
      Share.share(msg.mediaUrl!);
    }

  }

}

class ChatOps {
  // show peer avatar only once in a series of nessages
  static bool withoutAvatar(
      int i, int length, List<dynamic> messages, String peerId) {
    bool c1 = i != 0 && messages[i - 1].fromId == peerId;
    bool c2 = i != 0 && messages[i - 1].type != MessageType.Media;
    return c1 && c2;
  }

  // for adding border radius to all sides except for bottomRight/bottomLeft
  // if last message in a series from same user
  static bool isLast(int i, int length, List<dynamic> messages) {
    bool c1 = i != 0 && messages[i - 1].fromId == messages[i].fromId;
    bool c2 = i != 0 && messages[i - 1].type != MessageType.Media;
    return i == length - 1 || c1 && c2;
  }

  // for adding border radius to only topLeft/bottomLeft or topRight/bottomRight
  // if message is in the series of messages of one user
  static bool isMiddle(int i, int length, List<dynamic> messages) {
    bool c1 = i != 0 && messages[i - 1].fromId == messages[i].fromId;
    bool c2 = i != length - 1 && messages[i + 1].fromId == messages[i].fromId;
    return c1 && c2;
  }

  // opposite of isLast
  static bool isFirst(int i, int length, List<dynamic> messages) {
    bool c1 = i != 0 && messages[i - 1].fromId != messages[i].fromId;
    bool c2 = i != length - 1 && messages[i + 1].fromId == messages[i].fromId;
    return i == 0 || (c1 && c2);
  }
}


