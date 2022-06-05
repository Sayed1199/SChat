import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schat/constants.dart';
import 'package:schat/controllers/auth_controller.dart';
import 'package:schat/screens/phone_auth/phone_auth_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schat/widgets/laoding_indicator.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool isLoading=false;
  AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child:
       isLoading==false? Stack(
         children: [

           SafeArea(
             child: Stack(
               children: [
                 CustomPaint(
                   size: MediaQuery.of(context).size,
                   painter: TopLoginPathsPainter(),
                 ),

                 Align(
                   alignment: Alignment.topLeft,
                   child: Padding(
                     padding: const EdgeInsets.symmetric(horizontal:100,vertical: 50),
                     child: Text('Sign in',style: GoogleFonts.lato(
                       fontWeight: FontWeight.w600,
                       fontSize: 50,
                       color: Colors.white
                     ),),
                   ),
                 ),
               ],
             ),
           ),

           Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Image.asset('assets/images/login_logo_bg.png'),

                _GoogleSignInButton(onPressed: () async{
                  isLoading=true;
                  setState(() {
                  });
                    await authController.signInWithGoogle();
                },),

                _FacebookSignInButton(onPressed: ()async{
                  isLoading=true;
                  setState(() {
                  });
                  await authController.signInWFacebook();
                },),

                _PhoneSignInButton(onPressed: () {
                  print('moving');
                  Get.to(()=>PhoneAuthForm());
                },),


              ],
            ),




         ],
       ):LoadingWidget(mColor: Colors.blue),

      ),
    );
  }

}



class _PhoneSignInButton extends StatelessWidget {
  const _PhoneSignInButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return CupertinoButton(child: Container(
      width: size.width*0.85,
      height: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              Colors.green,
              Colors.teal,
            ]
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.phoneAlt,color: Colors.white,),
          SizedBox(width: 10,),
          Text(AppLocalizations.of(context)!.mobileSignIn,style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kBaseWhiteColor,
          ),)
        ],
      ),
    ),
        onPressed: onPressed);
  }
}


class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return CupertinoButton(child: Container(
      width: size.width*0.75,
      height: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              Colors.blue,
              Colors.red,
            ]
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.google,color: Colors.white,),
          SizedBox(width: 10,),
          Text(AppLocalizations.of(context)!.googleSignIn,style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kBaseWhiteColor,
          ),)
        ],
      ),
    ),
        onPressed: onPressed);
  }
}

class _FacebookSignInButton extends StatelessWidget {
  const _FacebookSignInButton({Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return CupertinoButton(child: Container(
      width: size.width*0.75,
      height: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.facebook,color: Colors.white,),
          SizedBox(width: 10,),
          Text(AppLocalizations.of(context)!.facebookSignIn,style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kBaseWhiteColor,
          ),)
        ],
      ),
    ),
        onPressed: onPressed);
  }
}

class TopLoginPathsPainter extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final path =  Path()
      ..moveTo(size.width * .6, 0)
      ..quadraticBezierTo(
        size.width * .7,
        size.height * .08,
        size.width * .9,
        size.height * .05,
      )
      ..arcToPoint(
        Offset(
          size.width * .93,
          size.height * .15,
        ),
        radius: Radius.circular(size.height * .05),
        largeArc: true,
      )
      ..cubicTo(
        size.width * .6,
        size.height * .15,
        size.width * .5,
        size.height * .46,
        0,
        size.height * .3,
      )
      ..lineTo(0, 0);

    paint.color=Colors.blue.withOpacity(0.7);
    path.moveTo(size.width, size.height);
    path.quadraticBezierTo(
      size.width,
      size.height*0.85,
      size.width * .5,
      size.height,
    );

    path.close();

    canvas.drawPath(path, paint);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
  
}

