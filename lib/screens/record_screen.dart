import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schat/constants.dart';
import 'package:schat/models/chat_model.dart';
import 'package:schat/models/message_model.dart';
import 'package:schat/services/database.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

enum RecordingState{
  UnSet,
  Set,
  Recording,
  Stopped,
}

class RecordScreen extends StatefulWidget {

  final Function onSaved;
  final ChatModel chatData;
  final DateTime time;

  const RecordScreen({Key? key,required this.onSaved,required this.chatData,required this.time}) : super(key: key);

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {

  bool hasFinishedrecording=false;

  RecordingState  _recordingState = RecordingState.UnSet;

   FlutterAudioRecorder2? _audiorecorder;

   String? recordPath;


  late int _totalDuration;
   int _currentDuration=0;
  double _completedPercentage = 0.0;
  bool _isPlaying = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FlutterAudioRecorder2.hasPermissions.then((hasPermission) {
        if(hasPermission != null){

          if(hasPermission){
            _recordingState = RecordingState.Set;
          }

        }
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    _recordingState = RecordingState.UnSet;
    _audiorecorder = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10,bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                 WaveWidget(
                  config: CustomConfig(
                    gradients: [
                      [Colors.orange, Color(0xEEF44336)],
                      [Colors.yellow[800]!, Color(0x77E57373)],
                      [Colors.pink, Color(0x66FF9800)],
                      [Colors.pinkAccent, Color(0x55FFEB3B)]
                    ],
                    durations: [35000, 19440, 10800, 6000],
                    heightPercentages: [0.20, 0.23, 0.25, 0.30],
                    blur: MaskFilter.blur(BlurStyle.solid, 10),
                    gradientBegin: Alignment.bottomLeft,
                    gradientEnd: Alignment.topRight,
                  ),
                  backgroundColor: Colors.transparent,
                  waveAmplitude: 10,
                  size: Size(
                    double.infinity,
                    MediaQuery.of(context).size.height*0.4,
                  ),
                ),


               _isPlaying? AvatarGlow(
                  glowColor: Colors.blue,
                  endRadius: 80.0,
                  duration: Duration(milliseconds: 1000),
                  repeat: true,
                  showTwoGlows: true,
                  repeatPauseDuration: Duration(milliseconds: 100),
                  child: Material(     // Replace this child with your own
                    elevation: 8.0,
                    shape: CircleBorder(),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Container(

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            _isPlaying? Text('${getTime(_currentDuration)}',style: GoogleFonts.lato(
                              fontSize: 20
                            ),):Container(width: 0,height: 0,),

                          ],
                        ),

                      ),
                      radius: 50.0,
                    ),
                  ),
                ): _recordingState==RecordingState.Recording? AvatarGlow(
                 glowColor: Colors.blue,
                 endRadius: 80.0,
                 duration: Duration(milliseconds: 1000),
                 repeat: true,
                 showTwoGlows: true,
                 repeatPauseDuration: Duration(milliseconds: 100),
                 child: Material(     // Replace this child with your own
                   elevation: 8.0,
                   shape: CircleBorder(),
                   child: CircleAvatar(
                     backgroundColor: Colors.transparent,
                     child: Container(

                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: [

                           _recordingState==RecordingState.Recording? Text('Recording',style: GoogleFonts.lato(
                               fontSize: 20
                           ),):Container(width: 0,height: 0,),

                         ],
                       ),

                     ),
                     radius: 50.0,
                   ),
                 ),
               ): Container(height: 0,width: 0,),


             !hasFinishedrecording?   GestureDetector(

                 onTap: ()async{

                   await toggleRecord();
                   setState(() {
                   });

                 },

                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _recordingState!=RecordingState.Recording? Colors.blue[800]:Colors.pink
                    ),
                    child: Icon(_recordingState==RecordingState.Recording?  CupertinoIcons.mic:CupertinoIcons.mic_off,size: 40,),
                  ),
                ):Container(width: 0,height: 0,),


              hasFinishedrecording?  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(

                      onTap: ()async{

                        await togglePlayStop(filePath: recordPath);


                      },

                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.purple[800]
                        ),
                        child: Icon(_isPlaying? CupertinoIcons.stop:CupertinoIcons.play,size: 40,),
                      ),
                    ),


                    GestureDetector(

                      onTap: ()async{

                        setState(() {
                          _isPlaying=false;
                          hasFinishedrecording=false;
                        });

                        Get.back();

                      },

                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red[800]
                        ),
                        child: Icon(CupertinoIcons.delete,size: 40,),
                      ),
                    ),
                  ],
                ):Container(width: 0,height: 0,),



                Visibility(
                  visible: hasFinishedrecording,
                  child: GestureDetector(

                    onTap: ()async{

                      await _uploadAudio();


                    },

                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal[800]
                      ),
                      child: Icon(Icons.done,size: 40,),
                    ),
                  ),
                ),




              ],
            ),
        ),
      ),

    );
  }

  String getTime(int secondsTime){
    String twoDigits(int n) => n.toString().padLeft(2,'0');
    final twoDigitsSeconds = twoDigits(secondsTime%60);
    final twoDigitsMinutes = twoDigits((secondsTime/60).toInt());
    return '$twoDigitsMinutes:$twoDigitsSeconds';
  }

  Future<void> toggleRecord() async{

    switch(_recordingState){
      case RecordingState.Set:
        await _recordVoice();
        break;

      case RecordingState.Recording:
        await _stopRecording();
        _recordingState = RecordingState.Stopped;
        break;

      case RecordingState.Stopped:
        await _recordVoice();
        break;

      case RecordingState.UnSet:
        final res =await Permission.microphone.request();
        if(res != PermissionStatus.granted){
          Fluttertoast.showToast(msg: 'pls give permission to the microphone',toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,backgroundColor: Colors.blue);
        }

    }

  }

  Future<void> _recordVoice() async{

    bool? hasPermission = await FlutterAudioRecorder2.hasPermissions;

    if(hasPermission!){

      await _initializeAudioRecorder();
      await _startAudioRecorder();

      _recordingState = RecordingState.Recording;

    }else{
      final res =await Permission.microphone.request();
      if(res != PermissionStatus.granted){
        Fluttertoast.showToast(msg: 'pls give permission to the microphone',toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,backgroundColor: Colors.blue);
      }
    }

  }

  Future<void> _stopRecording()async{
      await _audiorecorder!.stop();
      widget.onSaved;
      hasFinishedrecording=true;
  }

  Future<void> _initializeAudioRecorder() async{
      Directory appDirectory = await getApplicationDocumentsDirectory();
      String filePath = appDirectory.path + '/' + DateTime.now().millisecondsSinceEpoch.toString() + '.aac';
      String filePath2= appDirectory.path +'/'+'test.aac';
      if(await File(filePath2).exists()){
        File(filePath2).delete();
      }
      _audiorecorder = FlutterAudioRecorder2(filePath2,audioFormat: AudioFormat.AAC);
      recordPath = filePath2;
      await _audiorecorder!.initialized;
  }

  Future<void> _startAudioRecorder() async{

    await _audiorecorder!.start();
    await _audiorecorder!.current(channel: 0);

  }

  Future<void> togglePlayStop({String? filePath}) async{

    AudioPlayer audioPlayer = AudioPlayer();

    if(!_isPlaying){
      audioPlayer.play(recordPath!,isLocal: true);
      setState(() {
        _completedPercentage=0.0;
        _isPlaying=true;
      });

      audioPlayer.onPlayerCompletion.listen((event) {
        setState(() {
          _isPlaying=false;
          _completedPercentage=0.0;
        });
      });

      audioPlayer.onDurationChanged.listen((event) {
        setState(() {
          _totalDuration = event.inSeconds;
        });
      });

      audioPlayer.onAudioPositionChanged.listen((event) {
        setState(() {
          _currentDuration = event.inSeconds;
          _completedPercentage = _currentDuration.toDouble() / _totalDuration.toDouble();
        });
      });

    }

  }

  Future<void> _uploadAudio() async{

    Database db = Database();

    Get.defaultDialog(title: 'Uploading',content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Please wait',style: GoogleFonts.lato(
          fontSize: 18
        ),),
        SizedBox(width: 5,),
        CircularProgressIndicator(color: Colors.blue,)
      ],
    ));

    if(File(recordPath!) != null){
      print('null nooo');

      final Reference storageReference = FirebaseStorage.instance
          .ref(CHATS_MEDIA_STORAGE_REF)
          .child(widget.chatData.groupId).child('${widget.time.millisecondsSinceEpoch}');

      String downloadURL;

      UploadTask uploadTask = storageReference.putFile(File(recordPath!));

      downloadURL = await (await uploadTask).ref.getDownloadURL();

      print('Downlaod Url: ${downloadURL}');



      MessageModel msg = MessageModel(content: '',
          fromId: widget.chatData.userId,
          toId: widget.chatData.peerId,
          timeStamp: widget.time.millisecondsSinceEpoch.toString(),
          sendDate: widget.time,
          isSeen: false,
          type: MessageType.Media,
          mediaType: MediaType.Audio,
        mediaUrl: downloadURL,
        uploadFinished: false
      );

      widget.chatData.messages.insert(0, msg);
      db.addNewMessage(
        widget.chatData.groupId,
        widget.time,
        MessageModel.toJson(msg),
      );

      Get.back();
      Get.back();



    }


  }



}
