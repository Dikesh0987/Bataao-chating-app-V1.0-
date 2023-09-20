import 'dart:io';
import 'package:bataao/api/apis.dart';
import 'package:bataao/helper/dialogs.dart';
import 'package:bataao/screens/welcome_screen/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../theme/style.dart';
import '../main_screen/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Handel google btn
  _handleGoogleBtnClick() async {
    // catcj internet/wifi connection issue
    try {
      //checking internet connections ....
      await InternetAddress.lookup('google.com');

      // progress indicator ....
      MyProgressBars.showProgressBar(context);

      // Call google sign in function ....
      _signInWithGoogle().then((user) async {
        if (user != null) {
          // Get user Data from googlr
          print('\nUser : ${user.user}');
          print('\nUserAdditionalInfo : ${user.additionalUserInfo}');

          // Stop progress indicator
          Navigator.pop(context);

          if ((await APIs.userExists())) {
            //Redirect In Home page after succes fully Login
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MainScreen()));
          } else {
            await APIs.createUser().then((value) {
              //Redirect In Home page after succes fully Login
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => MainScreen()));
            });
          }
        }
      });
    } catch (e) {
      print("_signInWithGoogle : $e");

      // Show no internrt connections msg in snackbar ....
      DialogSnackBar.showSnackBar(context, "No Internet/wifi Connection !");
      return null;
    }
  }

  // For Google Sign Oprations...
  Future<UserCredential?> _signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await APIs.auth.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Stroke),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20),
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen())),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Body, borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: Colors.white,
                        ),
                      )),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Container(
                          width: 150,
                          height: 150,
                          child:
                              Image.asset("assets/logos/logo_transparent.png")),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        Colors.transparent,
                        Colors.white30,
                        Colors.white,
                        Colors.white
                      ])),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "We welcome you to\n this login method.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .8,
                              height: 50,
                              child: ElevatedButton(
                                  onPressed: () {
                                    _handleGoogleBtnClick();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 10,
                                      shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(30.0),
                                        side: BorderSide(color: Body),
                                      ),
                                      backgroundColor: Body),
                                  child: Text(
                                    'Log in with Google',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                        Text(
                          "By continuing, you agree to the Terms of Service and confirm that you have read our Privacy Policy.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Sky_Blue, fontSize: 12),
                        ),
                      ],
                    ),
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
