import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ThemeController extends GetxController{

  var isDarkModeEnabled;
  var modeText='Enable Light Mode';

  @override
  void onReady() async{
    // TODO: implement onReady
    super.onReady();
    final prefs = await SharedPreferences.getInstance();
    if(prefs.getString('mode')!=null) {
      if (prefs.getString('mode') == 'dark') {
        isDarkModeEnabled = Rx<bool>(true);
         modeText='Enable Light Mode';
      } else {
        isDarkModeEnabled = Rx<bool>(false);
         modeText='Enable Dark Mode';
      }
    }else{
      isDarkModeEnabled = Rx<bool>(true);
       modeText='Enable Light Mode';
    }
   ever(isDarkModeEnabled,_onThemeChanged);

  }


  _onThemeChanged(bool isDarModeEnabled) async{
    final prefs = await SharedPreferences.getInstance();
    if(isDarModeEnabled){
      print('Changed: dark now');
      Get.changeTheme(ThemeData.dark());
      modeText='Enable Light Mode';
      await prefs.setString('mode', 'dark');
    }else{
      print('Changed: light now');
      Get.changeTheme(ThemeData.light());
      modeText='Enable Dark Mode';
      await prefs.setString('mode', 'light');
    }

  }
}