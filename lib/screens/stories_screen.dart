import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schat/constants.dart';
import 'package:schat/controllers/auth_controller.dart';
import 'package:schat/controllers/chats_list_controller.dart';
import 'package:schat/controllers/stories_controller.dart';
import 'package:schat/controllers/theme_controller.dart';
import 'package:schat/models/story_model.dart';
import 'package:schat/models/user_model.dart';
import 'package:schat/services/database.dart';
import 'package:schat/services/storage.dart';
import 'package:schat/utils/utils.dart';
import 'package:schat/widgets/laoding_indicator.dart';


class StoriesScreen extends StatefulWidget {
  const StoriesScreen({Key? key}) : super(key: key);

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {


  ChatController chatController = Get.put(ChatController());
  AuthController authController = Get.put(AuthController());
  StoriesController storiesController = Get.put(StoriesController());
  ThemeController themeController = Get.put(ThemeController());

  File? _image;
  bool _mediaSelected = false;
  late final picker;
  late Storage storage;
  late FirebaseFirestore fstore;
  late UploadTask _uploadTask;

  bool uploadStarted = false;
  String? path;

  late int timeStamp;

  late Database db;

  List<UserModel> usersList=[];

  @override
  void initState(){
    super.initState();
    picker = ImagePicker();
    storage = Storage();
    fstore = FirebaseFirestore.instance;
    db = Database();
    storiesController.getMyStatuses().then((value){
      print('length: ${storiesController.storiesList.value.length}');
      List<int> indexesToDelete=[];
      storiesController.storiesList.value.forEach((element) {
        if(DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(element.timeStamp)).inHours >3){
          indexesToDelete.add(storiesController.storiesList.value.indexOf(element));
          storiesController.deleteStatus(element.timeStamp, element.statusSender);
        }
      });
      print('indexes: ${indexesToDelete}');
      indexesToDelete.reversed.forEach((element) {
        storiesController.storiesList.value.removeAt(element);
      });
      print('length now: ${storiesController.storiesList.value.length}');
      setState(() {
      });
    });

    FirebaseFirestore.instance.collection(USERS_COLLECTION).get().then((value) {
      value.docs.forEach((element) {
        usersList.add(UserModel.getUserModelFromJson(element.data() as Map<String,dynamic>));
        print('added: ${element.id}');
      });
      setState(() {
      });
    });


  }


  Future<bool> showImageSourceModal() async {
    return await showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          CupertinoButton(
            child:
            Text('Choose Photo', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          CupertinoButton(
            child: Text('Take Photo', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
        cancelButton: CupertinoButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).errorColor),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }


  Future getImage() async {
    var pickedFile = await Utils.pickImage(context);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _mediaSelected = true;
      });

      timeStamp = DateTime.now().millisecondsSinceEpoch;
      path = '$CHATS_MEDIA_STORAGE_REF/stories/${authController.firebaseUser.value!.uid}/$timeStamp';


      await storage.getUploadTask(_image!, path!);

      var url = await storage.getUrl(
          '$CHATS_MEDIA_STORAGE_REF/stories/${authController.firebaseUser.value!.uid}', '$timeStamp');

      print('Url: $url');

      StoryModel storyModel = StoryModel(
          statusSender: authController.firebaseUser.value!.uid,
          mediaUrl: url,
          timeStamp: timeStamp
      );

      await db.addStory(storyModel);

      Fluttertoast.showToast(msg: 'Status Uploaded',gravity: ToastGravity.BOTTOM,backgroundColor: Colors.blue,textColor: Colors.white);

      setState(() {
      });

    }
  }


  Widget _buildCreateStoryItem(User user) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CupertinoButton(
              padding: const EdgeInsets.all(0),
              onPressed: () => getImage(),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                          color: Colors.blue, width: 1.5),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.teal,
                      backgroundImage:
                      (user.photoURL != null && user.photoURL != '')
                          ? CachedNetworkImageProvider(user.photoURL!)
                          : null,
                      child: (user.photoURL == null || user.photoURL == '')
                          ? Icon(
                        Icons.person,
                        color: Colors.white,
                      )
                          : null,
                      radius: 27,
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 10),
            Text(
              // user.displayName.split(' ')[0],
              'Add Story',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: themeController.isDarkModeEnabled.value?Colors.white:Colors.black,
              ),
            ),

          ],
        ),
        SizedBox(height: 30,),

        Container(
          width: double.infinity,
          height: 20,
          color: Colors.transparent,
          child: Text('Recent Updates',style: GoogleFonts.actor(
            fontSize: 18,
          ),),
        ),

      ],
    );
  }


  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
      child: Column(

        children: [

          _buildCreateStoryItem(
              authController.firebaseUser.value!),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Stories').snapshots(),
                builder: (context,usersSnapshots){



                  if(usersSnapshots.hasData){

                    QuerySnapshot mSnapshot = usersSnapshots.data!;
                    print('msnapshots: ${mSnapshot.size}');
                    if(mSnapshot.size ==0){
                      return Container(width: 0,height: 0,);
                    }else{
                      return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('Stories').doc(authController.firebaseUser.value!.uid)
                              .collection('UserStories').snapshots(),
                          builder: (context,snapshots){
                            List<StoryModel> storiesListAsStoryModel = [];
                            if(snapshots.hasData) {


                              List<QueryDocumentSnapshot> storiesListAsDocSnapshot = snapshots
                                  .data!.docs;
                              if(storiesListAsDocSnapshot.length != 0) {
                                storiesListAsDocSnapshot.forEach((element) {
                                  storiesListAsStoryModel.add(
                                      StoryModel.fromJson(
                                          element.data() as Map<String, dynamic>));
                                });
                                print('snapshots: ${storiesListAsStoryModel.length}');

                                return Container(
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height,
                                  padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                                  child: ListView.separated(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(left: 15),
                                    scrollDirection: Axis.vertical,
                                    itemCount: mSnapshot.size,
                                    itemBuilder: (ctx, i) {
                                      print('i is: $i');



                                      return usersList.length>0? StoryViewItem(
                                        //authController.firebaseUser.value!,
                                        usersList.firstWhere((element) => element.id==mSnapshot.docs[i].id),
                                        storiesListAsStoryModel.length):Container(width: 0,height: 0,);

                                      },
                                    separatorBuilder: (_, __) => SizedBox(height: 30),
                                  ),
                                );
                              }else{
                                return Container(width: 0,height: 0,);
                              }
                            }
                            else{
                              return Center(child: LoadingWidget(mColor: Colors.blue));
                            }

                          });
                    }
                  }
                  return Container();

            }),
          ),
        ],
      ),
    );
    

  }
}


class StoryViewItem extends StatefulWidget {
  final UserModel? user;
  final numOfStatuses;
  StoryViewItem(this.user,this.numOfStatuses);
  @override
  _StoryViewItemState createState() => _StoryViewItemState();
}

class _StoryViewItemState extends State<StoryViewItem> {

  Widget _buildItem(UserModel? info) {
    return widget.user==null?Container(width: 0,height: 0,): Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () {},
          child:
    /*
    Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                /*
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.blue, width: 1.5),
                ),
                 */
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: (info.imageUrl != null && info.imageUrl != '')
                      ? CachedNetworkImageProvider(info.imageUrl!)
                      : null,
                  child: (info.imageUrl == null || info.imageUrl == '')
                      ? Icon(
                    Icons.person,
                    color: Colors.white,
                  )
                      : null,
                  radius: 27,
                ),
              ),

              /*
              CustomPaint(
                size: Size(60, 60),
                foregroundPainter:  MyPainter(
                    completeColor: Colors.blue,
                    width: 3),
              ),
               */



            ],
          ),
          */
          DottedBorder(
            color: Colors.blue.shade300,
            borderType: BorderType.Circle,
            radius: Radius.circular(30),
            dashPattern: [
              (2*pi*23)/widget.numOfStatuses,3
            ],
            strokeWidth: 3,
            child:  CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: (info!.imageUrl != null && info.imageUrl != '')
                  ? CachedNetworkImageProvider(info.imageUrl!)
                  : null,
              child: (info.imageUrl == null || info.imageUrl == '')
                  ? Icon(
                Icons.person,
                color: Colors.white,
              )
                  : null,
              radius: 27,
            ),
          ),
        ),

        SizedBox(
          width: 100,
          child: Center(
            child: Text(
              info.username!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildItem(widget.user);
  }
}

class MyPainter extends CustomPainter {
  Color lineColor =  Colors.transparent;
  Color? completeColor;
  double? width;
  MyPainter(
      { this.completeColor, this.width});
  @override
  void paint(Canvas canvas, Size size) {
    Paint complete = new Paint()
      ..color = completeColor!
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width!;

    Offset center = new Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    var percent = (size.width *0.001) / 2;

    double arcAngle = 2 * pi * percent;
    print("$radius - radius");
    print("$arcAngle - arcAngle");
    print("${radius / arcAngle} - divider");

    for (var i = 0; i < 8; i++) {
      var init = (-pi / 2)*(i/2);

      canvas.drawArc(new Rect.fromCircle(center: center, radius: radius),
          init, arcAngle, false, complete);
    }


  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}