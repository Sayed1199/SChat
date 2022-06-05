import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:schat/controllers/auth_controller.dart';
import 'package:schat/controllers/theme_controller.dart';
import 'package:schat/widgets/laoding_indicator.dart';

class PhoneAuthForm extends StatefulWidget {
  const PhoneAuthForm({Key? key}) : super(key: key);

  @override
  State<PhoneAuthForm> createState() => _PhoneAuthFormState();
}

class _PhoneAuthFormState extends State<PhoneAuthForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController phoneNumber = TextEditingController();
  OtpFieldController otpController = OtpFieldController();


  bool isOTPVisible = false;
  bool isOTPObsecure = true;
  String? verificationId;
  String countryCode = '+2';
  String otpCode='';
  AuthController authController = Get.put(AuthController());
  ThemeController themeController = Get.put(ThemeController());

  bool loading = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    phoneNumber.text=countryCode;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      //resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Phone Login",
            style: GoogleFonts.lato(
              fontSize: 20,
                color: themeController.isDarkModeEnabled.value==true?
                Colors.white:Colors.black
            ),
          ),
          leading: Builder(builder: (context){
            return IconButton(onPressed: (){
              Get.back();
            }, icon: Icon(CupertinoIcons.left_chevron,color: themeController.isDarkModeEnabled.value==true?
            Colors.white:Colors.black,size: 30,));
          }),
        ),
        body:  Center(
          child: loading?LoadingWidget(mColor: Colors.blue): ListView(
            //mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Image.asset('assets/images/login_mobile_logo.png'),

              Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: size.width * 0.85,
                        child: TextFormField(
                          onChanged: (value){
                          },
                            onFieldSubmitted: (value){
                            print('Submitted: $value');
                            },
                            keyboardType: TextInputType.phone,
                            controller: phoneNumber,
                            decoration: InputDecoration(
                              labelText: "Enter Phone",
                              labelStyle: GoogleFonts.lato(fontSize: 18),
                              prefixIcon: CountryCodePicker(
                                onChanged: (CountryCode code) {
                                  print('Country Code: $code');
                                  phoneNumber.text=code.dialCode!;
                                  setState(() {
                                  });
                                },
                                // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                initialSelection: 'EG',
                                favorite: ['+2', 'EG'],
                                // optional. Shows only country name and flag
                                showCountryOnly: false,
                                // optional. Shows only country name and flag when popup is closed.
                                showOnlyCountryWhenClosed: true,
                                // optional. aligns the flag and the Text left
                                alignLeft: false,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 25.0, horizontal: 10.0),
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1.5),
                                borderRadius: BorderRadius.circular(35),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      !isOTPVisible
                          ? Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(35),
                                    border:
                                        Border.all(color: Colors.blue, width: 1.5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      OTPTextField(
                                        keyboardType: TextInputType.number,
                                        controller: otpController,
                                        obscureText: isOTPObsecure,
                                        length: 6,
                                        width: size.width * 0.6,
                                        fieldWidth: 30,
                                        style: GoogleFonts.lato(fontSize: 20,
                                            color: themeController.isDarkModeEnabled.value==true?Colors.white:Colors.black),
                                        textFieldAlignment:
                                            MainAxisAlignment.spaceAround,
                                        fieldStyle: FieldStyle.underline,
                                        otpFieldStyle: OtpFieldStyle(backgroundColor: Colors.white),
                                        onChanged: (pin){
                                          otpCode=pin;
                                          print('changed: $pin');
                                          setState(() {
                                          });
                                        },
                                        onCompleted: (pin) {
                                          print('otp: ${pin}');
                                          otpCode=pin;
                                          setState(() {
                                          });
                                        },
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                          onTap: () {
                                            print('hh');
                                            isOTPObsecure = !isOTPObsecure;
                                            setState(() {});
                                          },
                                          child: FaIcon(
                                            isOTPObsecure? FontAwesomeIcons.eye:FontAwesomeIcons.eyeSlash,
                                            color: Colors.blue,
                                            size: 22,
                                          ))
                                    ],
                                  ),
                                ),
                                Positioned(
                                    left: 50,
                                    top: -2,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          bottom: 10, left: 10, right: 10),
                                      color: Colors.transparent,
                                      child: Text(
                                        'OTP',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    )),
                              ],
                            )
                          : Container(),
                      Padding(padding: EdgeInsets.only(bottom: size.height * 0.05)),
                      OutlinedButton(
                          onPressed: () async {
                            if (isOTPVisible) {
                              await authController.verifyCode(verificationId,otpCode);
                            } else {
                              await verifyPhoneNumber();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(35),
                              border: Border.all(
                                color: Colors.blue,
                                width: 1.5
                              ),
                            ),
                            child: Text(
                              isOTPVisible ? 'Sign in' : 'Verify',
                              style: GoogleFonts.lato(fontSize: 22),
                            ),
                          ),
                          style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all<Color>(Colors.white),
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.transparent),
                              side: MaterialStateProperty.all<BorderSide>(
                                  BorderSide.none)),
                        ),

                    ],
                  ),
              ),
            ],
          ),
        ));
  }

  Future<void> verifyPhoneNumber() async {
    print('text: ${phoneNumber.text}');
    setState(() {
      loading=true;
    });
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.text,
        timeout: Duration(seconds: 30),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential).then((value) {
            print('LoggedIn Successfully');
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          Fluttertoast.showToast(
              msg: 'smth wrong happended: $e',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.blue);
          print('errorrr: $e');
          setState(() {
            loading=false;
          });
        },
        codeSent: (String verificationID, int? requestToken) {
          verificationId = verificationID;
          isOTPVisible = true;
          loading=false;
          setState(() {});
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          loading=false;
          Fluttertoast.showToast(
              msg: 'Code Time Out, pls verify again',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.blue);
          setState(() {
          });
          return null;
        });

  }


}
