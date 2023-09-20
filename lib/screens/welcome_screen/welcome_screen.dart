import 'package:bataao/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';

import '../../theme/style.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Stroke),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Container(
                        width: 150,
                        height: 150,
                        child:
                            Image.asset("assets/logos/logo_transparent.png")),
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
                          height: 50,
                        ),
                        Text(
                          "We welcome you to\n Bataao",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: cTitle,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        Column(
                          children: [
                            // SizedBox(
                            //   width: MediaQuery.of(context).size.width * .8,
                            //   height: 50,
                            //   child: ElevatedButton(
                            //       onPressed: () {},
                            //       style: ElevatedButton.styleFrom(
                            //           elevation: 10,
                            //           shape: new RoundedRectangleBorder(
                            //             borderRadius:
                            //                 new BorderRadius.circular(30.0),
                            //             side: BorderSide(
                            //                 color: Color(0xff050A30)),
                            //           ),
                            //           backgroundColor: Color(0xff050A30)),
                            //       child: Text(' Register')),
                            // ),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .8,
                              height: 50,
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()));
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
                                    ' Log in / Ragistration',
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
