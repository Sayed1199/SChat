import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schat/constants.dart';
import 'package:schat/models/user_model.dart';
import 'package:schat/screens/login_screen.dart';
import 'package:schat/screens/home.dart';
import 'package:schat/services/database.dart';

class AuthController extends GetxController{

 FirebaseAuth auth = FirebaseAuth.instance;
 FirebaseFirestore fstore = FirebaseFirestore.instance;
 GoogleSignIn googleSignIn = GoogleSignIn();

 Database db = Database();

 late Rx<User?> firebaseUser;
 late Rx<GoogleSignInAccount?> googleSignInAccount;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();

    firebaseUser = Rx<User?>(auth.currentUser);
    googleSignInAccount = Rx<GoogleSignInAccount?>(googleSignIn.currentUser);

    firebaseUser.bindStream(auth.userChanges());
    ever(firebaseUser, _setScreensFromNormalUser);

    googleSignInAccount.bindStream(googleSignIn.onCurrentUserChanged);
    ever(googleSignInAccount, _setScreensFromGoogleUser); 

  }


  _setScreensFromNormalUser(User? user) async {
   if(user==null){
    Get.offAll(()=>LoginScreen());
   }else{
    Get.offAll(()=>HomeScreen(),arguments: 'hi');
   }
  }

  _setScreensFromGoogleUser(GoogleSignInAccount? googleUser) async {
   if(googleUser==null){
    Get.offAll(()=>LoginScreen());
   }else{
    Get.offAll(()=>HomeScreen(),arguments: 'hi');
   }
  }


 Future<void> signInWithGoogle() async {
  try {
   GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

   if (googleSignInAccount != null) {
    GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
     accessToken: googleSignInAuthentication.accessToken,
     idToken: googleSignInAuthentication.idToken,
    );

    await auth
        .signInWithCredential(credential)
        .catchError((onErr) => print(onErr));


    if(firebaseUser.value != null) {

     UserModel model = UserModel(id: firebaseUser.value!.uid,
      username: firebaseUser.value!.displayName == null?null:firebaseUser.value!.displayName,
      email: firebaseUser.value!.email != null?firebaseUser.value!.email! : null,
      imageUrl: firebaseUser.value!.photoURL != null?firebaseUser.value!.photoURL! : null,
      phoneNumber: firebaseUser.value!.phoneNumber != null?firebaseUser.value!.phoneNumber! : null,
     );

     await db.addUser(model);

    }else{
     print('Null User');
    }


   }
  } catch (e) {
   Get.snackbar(
    "Error",
    e.toString(),
    snackPosition: SnackPosition.BOTTOM,
   );
   print(e.toString());
  }
 }



 Future<void> signInWFacebook()async{
  try{
   final LoginResult loginResult = await FacebookAuth.instance.login();
   final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

   await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

   final graphResponse = await http.get(Uri.parse(
       'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${loginResult.accessToken!.token}'));

   String imageUrl = jsonDecode(graphResponse.body)['picture']['data']['url'];

   UserModel model = UserModel(id: firebaseUser.value!.uid,
    username: firebaseUser.value!.displayName == null?null:firebaseUser.value!.displayName,
    email: firebaseUser.value!.email != null?firebaseUser.value!.email! : null,
    imageUrl: imageUrl != null? imageUrl : null,
    phoneNumber: firebaseUser.value!.phoneNumber != null?firebaseUser.value!.phoneNumber! : null,
   );

   await db.addUser(model);

  }catch(e){
   Get.snackbar(
    "Error",
    e.toString(),
    snackPosition: SnackPosition.BOTTOM,
   );
   print(e.toString());
  }
 }

 Future<void> verifyCode(String? verificationId,String otpCode) async {
  PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId!, smsCode: otpCode);
  await auth.signInWithCredential(credential).then((value) async{

   print('You Are Logged in');
   Fluttertoast.showToast(
       msg: 'Logged in successfully',
       toastLength: Toast.LENGTH_SHORT,
       gravity: ToastGravity.BOTTOM,
       backgroundColor: Colors.blue);

   UserModel model = UserModel(id: firebaseUser.value!.uid,
    username: firebaseUser.value!.displayName == null?firebaseUser.value!.phoneNumber:firebaseUser.value!.displayName,
    email: firebaseUser.value!.email != null?firebaseUser.value!.email! : null,
    imageUrl: firebaseUser.value!.photoURL != null?firebaseUser.value!.photoURL! : anonPic,
    phoneNumber: firebaseUser.value!.phoneNumber != null?firebaseUser.value!.phoneNumber! : null,
   );
   await db.addUser(model);
  });
 }

 Future<void> signOut()async{
   await auth.signOut();
 }

}