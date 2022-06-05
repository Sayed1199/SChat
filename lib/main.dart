import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:schat/controllers/auth_controller.dart';
import 'package:schat/controllers/theme_controller.dart';
import 'package:schat/widgets/laoding_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  print('notification title: ${message.data['title']}');
  flutterLocalNotificationsPlugin.show(message.hashCode,message.data['title'],message.data['body'],
  NotificationDetails(
    android: AndroidNotificationDetails(
      channel.id,
      channel.name,
      icon: message.notification?.android?.smallIcon,
    ),
  )
  );

}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");


  await Firebase.initializeApp().then((value)async {

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    Get.put(ThemeController());
    final prefs = await SharedPreferences.getInstance();
    final String? readPrefs = prefs.getString('mode');
    if(readPrefs != null){
      if(readPrefs=='dark'){
        print('Moide: dark');
        Get.changeTheme(ThemeData.dark());
      }else if(readPrefs=='light'){
        print('Moide: light');
        Get.changeTheme(ThemeData.light());
      }else{
      }
    }else{
      print('Moide: null');
      await prefs.setString('mode', 'dark');
      Get.changeTheme(ThemeData.dark());
      ThemeController().isDarkModeEnabled.value=true;
    }

     Get.put(AuthController());

  });


  runApp(const MyApp());
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title// description
  importance: Importance.high,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SChat',
      debugShowCheckedModeBanner: false,

      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      home: Scaffold(
        body: Center(
          child: LoadingWidget(mColor: Colors.blue,),
        ),
      ),


    );
  }
}
