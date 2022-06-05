import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schat/constants.dart';
import 'package:schat/controllers/theme_controller.dart';
import 'package:schat/models/user_model.dart';
import 'package:schat/screens/home.dart';
import 'package:schat/screens/video_call_screen.dart';
import 'package:schat/widgets/avatar.dart';

class ChatItemAppbar extends StatefulWidget {
  final UserModel peer;
  final String groupId;
  ChatItemAppbar(this.peer, this.groupId);
  @override
  _ChatItemAppbarState createState() => _ChatItemAppbarState();
}

class _ChatItemAppbarState extends State<ChatItemAppbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _animation;

  late Timer _timer;
  bool collapsed = false;
  var stream;

  ThemeController themeController = Get.put(ThemeController());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    // steram of peer details

    stream = FirebaseFirestore.instance
        .collection(USERS_COLLECTION)
        .doc(widget.peer.id)
        .snapshots();


    _animation = Tween(begin: 1.0, end: 0.0).animate(_animationController);


    _timer = Timer(Duration(seconds: 3), () {
      collapse();
    });

  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.removeListener(() {});
    _animationController.dispose();
    super.dispose();
  }

  void collapse() {
    _animationController.forward();
    Future.delayed(Duration(milliseconds: 300)).then((value) {
      if (this.mounted) setState(() => collapsed = true);
    });
  }

  void goToContactDetails() {
    print('Go To Details');
  }

  bool tapped = false;
  void toggle() {
    setState(() {
      tapped = !tapped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      // centerTitle: true,
      elevation: 0,
      leading: IconButton(onPressed: (){


        Get.offAll(()=>HomeScreen());



        }, icon: Icon(CupertinoIcons.left_chevron,
        color: themeController.isDarkModeEnabled.value==true?Colors.white:Colors.black,)),
      title: CupertinoButton(
        padding: const EdgeInsets.all(0),
        onPressed: goToContactDetails,
        child: Row(
          children: [
            Avatar(imageUrl: widget.peer.imageUrl!, radius: kToolbarHeight / 2 - 5),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.peer.username!, style: GoogleFonts.lato(
                  fontSize: 18,
                  color: themeController.isDarkModeEnabled.value==true?Colors.white:Colors.black
                )),
                if (collapsed)
                  StreamBuilder(
                      stream: stream,
                      builder: (ctx, snapshot) {
                        if (!snapshot.hasData)
                          return Container(width: 0, height: 0);
                        else {

                          DocumentSnapshot<Map<String,dynamic>> documentSnapshot = snapshot.data as DocumentSnapshot<Map<String,dynamic>>;
                          Map<String,dynamic>? mMap = documentSnapshot.data();
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: mMap!= null? mMap['isOnline']==null?0 : 13:0,
                            child: Text(
                              'Online',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.blue[800],
                              ),
                            ),
                          );
                          // return Container();
                        }
                      }),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                  height: collapsed ? 0 : 13,
                  child: FadeTransition(
                    opacity: _animation,
                    child: Text(
                      'tap for more info',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: themeController.isDarkModeEnabled.value==true?Colors.white.withOpacity(0.7)
                            :Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20, top: 5, bottom: 5),
          child: Wrap(
            children: [
              /*
              CupertinoButton(
                onPressed: makeVoiceCall,
                padding: const EdgeInsets.all(0),
                child: Icon(Icons.call, color: Colors.blue[500]),
                // Avatar(imageUrl: widget.peer.imageUrl, radius: 23, color: kBlackColor3),
              ),
              */
              CupertinoButton(
                onPressed: makeVideoCall,
                padding: const EdgeInsets.all(0),
                child: Icon(FontAwesomeIcons.phone,
                    color: Colors.blue[500],size: 30,),
                // Avatar(imageUrl: widget.peer.imageUrl, radius: 23, color: kBlackColor3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void makeVoiceCall() {
    print('Voice Call');
  }

  void makeVideoCall() {

    Get.to(()=>VideoCallingScreen(groupID: widget.groupId));

    print('Video Call');

  }
}
