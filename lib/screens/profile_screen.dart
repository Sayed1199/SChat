import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schat/controllers/auth_controller.dart';
import 'package:schat/models/user_model.dart';
import 'package:schat/services/database.dart';
import 'package:schat/widgets/laoding_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  UserModel? curUser;
  Database db = Database();
  AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    db.getCurUserAsUserModel(authController.firebaseUser.value!.uid).then((value) {
      curUser = value;
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: curUser ==null?LoadingWidget(mColor: Colors.blue.shade400):
        Padding(
          padding: const EdgeInsets.only(top: 50,bottom: 20),
          child: ListView(

            children: [

              Center(
                child: Stack(
                  children: [

                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          image: DecorationImage(image:NetworkImage(curUser!.imageUrl!),
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high
                          )
                      ),
                    ),

                    Positioned(
                      bottom: 10,
                      right: 0,
                      child:CircleAvatar(radius: (25),
                          backgroundColor: Colors.black54,
                          child: ClipRRect(
                            borderRadius:BorderRadius.circular(50),
                            child: Icon(CupertinoIcons.photo_camera,size: 40,color: Colors.white,),
                          )
                      )

                    )


                  ],
                ),
              ),

              SizedBox(height: 50,),

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20,right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Username',style: GoogleFonts.adamina(
                          fontSize: 20
                              ,color: Colors.blue
                      ),),
                      SizedBox(width: 20,),
                      Text(curUser!.username!,style: GoogleFonts.lato(
                        fontSize: 22,
                      ),),
                    ],
                  ),
                ),
              ),


            ],

          ),
        ),
      ),

    );
  }
}
