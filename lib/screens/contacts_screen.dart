import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schat/controllers/chats_list_controller.dart';
import 'package:schat/models/user_model.dart';
import 'package:schat/services/database.dart';
import 'package:schat/widgets/laoding_indicator.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {

  ChatController chatController  = Get.put(ChatController());
  late Database db;
  List<UserModel>? usersList;

  void getData()async{
    db.getContactsAsUserModels().then((value) {
      print('value: $value');
      setState(() {
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    db = Database();

    db.getContactsAsUserModels().then((value){
      print('value: ${value}');
      usersList = value;
      setState(() {
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: chatController.contacts.value.length==0?Center(
        child: Text('No Contacts yet...',style: GoogleFonts.aclonica(
          fontSize: 20,
        ),),
      ):ListView.separated(
          itemBuilder: (context, index)
    {
      if(usersList != null){
        print('idd: ${usersList!.length}');
        print('indexxxx: ${index}');
      }

      return
        usersList == null? Center(child: LoadingWidget(mColor: Colors.blue)) :
       usersList!.isEmpty?Center(child: LoadingWidget(mColor: Colors.blue)):
       Padding(
        padding: const EdgeInsets.only(left: 20,top: 20,right: 20,bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 60,width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(backgroundImage: NetworkImage(usersList![index].imageUrl!),
                  backgroundColor: Colors.transparent,
                )
            ),
            SizedBox(width: 10,),
            Text(usersList![index].username!,style: GoogleFonts.play(
              fontSize: 20
            ),),

          ],
        ),

      );


    },
          separatorBuilder: (context,index) => Divider(
            height: 10,
            color: Colors.blue.shade500,
          ),
          itemCount: chatController.contacts.value.length
      ),

    );
  }
}
