import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:schat/controllers/auth_controller.dart';
import 'package:schat/controllers/theme_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    ThemeController themeController = Get.put(ThemeController());
    AuthController authController = Get.put(AuthController());

    return Container(
      margin: EdgeInsets.symmetric(vertical: 50),
      child: ClipRRect(
        borderRadius:Localizations.localeOf(context).toString()=='ar'? BorderRadius.only(topLeft: Radius.circular(35),bottomLeft: Radius.circular(70)) : BorderRadius.only(topRight: Radius.circular(35),bottomRight: Radius.circular(70)),
        child: Drawer(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                GestureDetector(
                  onTap: (){
                   themeController.isDarkModeEnabled.value = !themeController.isDarkModeEnabled.value;
                  },
                  child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(35),
                          color: Colors.pink
                      ),
                      child:
                      Obx(()=> Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: (){}, icon: themeController.isDarkModeEnabled.value==true? Icon(FontAwesomeIcons.solidSun,):
                          Icon(FontAwesomeIcons.moon),iconSize: 30,),
                          Text(themeController.modeText,style: TextStyle(fontSize: 22),),
                        ],
                      ))),
                ),


                SizedBox(height: 20,),


                GestureDetector(
                    onTap: (){
                    },
                    child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(35),
                            color: Colors.cyan
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(onPressed: (){
                            }, icon:Icon(FontAwesomeIcons.home),iconSize: 30,),
                            SizedBox(width: 10,),
                            Text(AppLocalizations.of(context)!.drawerSettings,style: TextStyle(fontSize: 22),),
                          ],
                        ))),

                SizedBox(height: 20,),

                GestureDetector(
                  onTap: (){
                    authController.signOut();
                  },
                  child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(horizontal: 60),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(35),
                          color: Colors.pinkAccent
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: (){}, icon: Icon(FontAwesomeIcons.doorOpen),iconSize: 30,),
                          SizedBox(width: 5,),
                          Text(AppLocalizations.of(context)!.drawerSignOut,style: TextStyle(fontSize: 22),),
                        ],
                      )),
                ),




              ],

            ),
          ),
        ),

      ),
    );
  }
}
