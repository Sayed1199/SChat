import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:schat/controllers/auth_controller.dart';
import 'package:schat/controllers/theme_controller.dart';
import 'package:schat/models/message_model.dart';
import 'package:get/get.dart';
import 'package:schat/widgets/avatar.dart';
import 'package:schat/widgets/dismissible_bubble.dart';

AuthController authController = Get.put(AuthController());

class AudioBubble extends StatefulWidget {
  final MessageModel message;
  final Function onReplied;
  final String avatarImageUrl;
  const AudioBubble({Key? key,required this.message,required this.onReplied
    ,required this.avatarImageUrl
  }) : super(key: key);

  @override
  State<AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<AudioBubble> {

  int maxDuration = 0;
  int currentPos = 0;
  String currentPostLabel = "00:00";
  bool isPlaying = false;
  bool audioPlayed = false;

  AudioPlayer audioPlayer = AudioPlayer();

  ThemeController themeController = Get.put(ThemeController());

  @override
  void initState() {
    // TODO: implement initState

    Future.delayed(Duration.zero,()async{

      audioPlayer.onPlayerCompletion.listen((event) {
        isPlaying=false;
        setState(() {
        });
      });


      audioPlayer.onDurationChanged.listen((Duration d) {
        maxDuration = d.inMilliseconds;
        setState(() {
        });
      });

      audioPlayer.onAudioPositionChanged.listen((Duration d) {

        currentPos = d.inMilliseconds;

        int shours = Duration(milliseconds:currentPos).inHours;
        int sminutes = Duration(milliseconds:currentPos).inMinutes;
        int sseconds = Duration(milliseconds:currentPos).inSeconds;

        int rhours = shours;
        int rminutes = sminutes - (shours * 60);
        int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);

        currentPostLabel = "$rhours:$rminutes:$rseconds";

        setState(() {
        });
      });
    });

    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMe =
        authController.firebaseUser.value!.uid == widget.message.fromId;

    return  Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe?MainAxisAlignment.end:MainAxisAlignment.start,
        children: [

          if (!isMe) Avatar(imageUrl: widget.avatarImageUrl),
          if (!isMe) SizedBox(width: 5),


          DismssibleBubble(
            isMe: isMe,
            message: widget.message,
            onDismissed: widget.onReplied,

            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                height:40,
                width: size.width*0.6,
                decoration: BoxDecoration(
                  color: themeController.isDarkModeEnabled.value==true?Colors.black38:Colors.blueGrey,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    GestureDetector(
                        onTap: ()async{
                          if(!isPlaying && !audioPlayed){
                            int result = await audioPlayer.play(widget.message.mediaUrl!);
                            if(result == 1){ //play success
                              setState(() {
                                isPlaying = true;
                                audioPlayed = true;
                              });
                            }else{
                              print("Error while playing audio.");
                            }
                          }else if(audioPlayed && !isPlaying){
                            int result = await audioPlayer.resume();
                            if(result == 1){ //resume success
                              setState(() {
                                isPlaying = true;
                                audioPlayed = true;
                              });
                            }else{
                              print("Error on resume audio.");
                            }
                          }else{
                            int result = await audioPlayer.pause();
                            if(result == 1){ //pause success
                              setState(() {
                                isPlaying = false;
                              });
                            }else{
                              print("Error on pause audio.");
                            }
                          }
                        },
                        child: Icon(isPlaying?CupertinoIcons.pause_circle:CupertinoIcons.play_circle,size: 28,)),


                    Container(
                      width: size.width/3,
                      child: NeumorphicSlider(
                        style: SliderStyle(
                          depth: 4,
                          borderRadius: BorderRadius.circular(25),
                          accent: Colors.pink,
                          variant: Colors.blue,
                          //lightSource: LightSource.,
                        ),
                        min:0,
                        value:double.parse(currentPos.toString()),
                        max: double.parse(maxDuration.toString()),
                        height: 10,

                        onChanged: (double value)async{
                          int seekval = value.round();
                          int result = await audioPlayer.seek(Duration(milliseconds: seekval));
                          if(result == 1){ //seek successful
                            currentPos = seekval;
                          }else{
                            print("Seek unsuccessful.");
                          }
                        },

                      ),
                    ),
                    Text('$currentPostLabel'),
                  ],
                ),
            ),

          ),


        ],
    );
  }
}
