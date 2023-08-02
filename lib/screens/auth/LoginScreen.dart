import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talkster_chatting_app/ThemeColor.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:talkster_chatting_app/helper/dialog.dart';

import '../../api/Api.dart';
import '../../main.dart';
import '../HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        isAnimate = true;
      });
    });
  }

  _onSigInBtn() {
    Dialogs.newProgressBar(context);
    signInWithGoogle().then((user) async => {
          Navigator.pop(context),
          if (user != null)
            {
              log('"User: " ${user.user}'),
              log('"\nUserAdditionalInfo: " ${user.additionalUserInfo}'),
              if (await APIs.isUserExists())
                {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => HomeScreen()))
                }
              else
                {
                  APIs.CreateNewUser().then((value) =>
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => HomeScreen())))
                }
            }
        });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      InternetAddress.lookup("google.com");
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
    } catch (e) {
      log("_singinwithgoogle: $e");
      Dialogs.newSnackBar(
          context, "something went wrong (Check the internet!)");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Talkster",
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height * .06,
              right: isAnimate ? mq.width * .20 : -mq.width * .7,
              width: mq.width * .6,
              duration: Duration(seconds: 3),
              child: Image.asset("assets/images/App_Icon.png")),
          Positioned(
            top: mq.height * .37,
            left: mq.width * .08,
            width: mq.width * .80,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                      hintText: "Username",
                      labelText: "Enter Username",
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 130, 130, 177))),
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Password",
                    labelText: "Enter Password",
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 130, 130, 177),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => HomeScreen()));
                  },
                  child: Text("Login"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 40),
                    backgroundColor: clr,
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
          Positioned(
            bottom: mq.height * .18,
            width: mq.width * 1.0,
            height: mq.height * .06,
            child: Divider(
              color: const Color.fromARGB(255, 199, 199, 199),
              height: 28,
              thickness: 1,
              indent: 2,
              endIndent: 5,
            ),
          ),
          Positioned(
            bottom: mq.height * .10,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .06,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 1,
                backgroundColor: Color.fromARGB(255, 130, 130, 177),
                shape: StadiumBorder(),
              ),
              onPressed: () {
                _onSigInBtn();
              },
              icon: Image.asset(
                "assets/images/google_logo.png",
                height: 30,
              ),
              label: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 17),
                  children: [
                    TextSpan(text: "Sign In with "),
                    TextSpan(
                      text: "Google",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
