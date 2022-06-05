import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VideoCallingScreen extends StatefulWidget {

      final String groupID;

  const VideoCallingScreen({Key? key,required this.groupID}) : super(key: key);

  @override
  State<VideoCallingScreen> createState() => _VideoCallingScreenState();
}

class _VideoCallingScreenState extends State<VideoCallingScreen> {

  final AgoraClient _client = AgoraClient(agoraConnectionData:
  AgoraConnectionData(
    // go to agora.io and edit this data this is a temp token generate new one with same channel name
      appId: dotenv.get('AGORA_APP_ID'),
      channelName: 'fluttering',
      tempToken: dotenv.get('AGORA_TEMP_TOKEN')
        ),
      );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora()async{
    await _client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async=>false,
      child: Scaffold(

        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Video Call'),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),

        body: SafeArea(child: Stack(
          children: [
            AgoraVideoViewer(
                client: _client,
                layoutType: Layout.floating,
                showNumberOfUsers: true,
                showAVState: true,
            ),
            AgoraVideoButtons(
                client: _client,
                autoHideButtons: false,
                enabledButtons: [
                  BuiltInButtons.toggleCamera,
                  BuiltInButtons.callEnd,
                  BuiltInButtons.toggleMic,
                ],
            )
          ],
        )),

      ),
    );
  }
}
