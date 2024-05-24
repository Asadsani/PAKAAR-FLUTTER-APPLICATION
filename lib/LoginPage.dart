// ignore: file_names

// ignore_for_file: unused_import, unused_local_variable, avoid_print, non_constant_identifier_names, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pakaar_t2/Forgetpassword.dart';
import 'package:pakaar_t2/SignUpscreen.dart';
import 'package:pakaar_t2/userprofile.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();
  bool showspinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ModalProgressHUD(
      inAsyncCall: showspinner,
      child: SafeArea(
          child: Stack(children: [
        //pakaar logo

        //login buttton

        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Pakaar',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Epilogue',
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 30,
                  right: 9,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(() => SignUpscreen());
                      },
                      child: Container(
                        width: 100,
                        height: 50,
                        decoration: BoxDecoration(
                            border: Border.all(width: 2),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
                        child: const Center(
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 50),
                    child: Text('Log In',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),

              //Full Name label

              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 50),
                    child: Text(
                      'Email ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'inter',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 60,
                width: 400,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 40),
                  child: TextField(
                    controller: loginEmailController,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Email address'),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: Text(
                      'Password ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'inter',
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 10,
              ),

              Container(
                height: 60,
                width: 400,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 22.0),
                  child: TextField(
                    controller: loginPasswordController,
                    obscureText: true,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Password'),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(() => Forgetpassword());
                      },
                      child: Text(
                        "Forgot Password ",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: "inter"),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),

              //login bitton
              InkWell(
                onTap: () async {
                  var loginEmail = loginEmailController.text.trim();
                  var loginPassword = loginPasswordController.text.trim();
                  setState(() {
                    showspinner = false;
                  });
                  try {
                    final User? FirebaseUser = (await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: loginEmail, password: loginPassword))
                        .user;
                    if (FirebaseUser != null) {
                      Get.to(() => UserProfilePage());
                    } else {
                      print("Error");
                    }
                    setState(() {
                      showspinner = true;
                    });
                  } on FirebaseAuthException catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Wrong"),
                        content: Text('Wrong Email Or Password'),
                        actions: [
                          TextButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                    );
                  }
                },
                child: Container(
                  width: 355,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12),
                    ),
                    color: Color.fromRGBO(51, 255, 119, 100),
                  ),
                  child: Center(
                      child: Text(
                    'Log In',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  )),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "OR",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'inter',
                      fontWeight: FontWeight.w700,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 40,
              ),

              InkWell(
                onTap: () async {
                  // begin interactive sign in process
                  final GoogleSignInAccount? gUser =
                      await GoogleSignIn().signIn();
                  // obtaiin auth details from request
                  final GoogleSignInAuthentication gAuth =
                      await gUser!.authentication;
                  // create a new credential for user
                  final credential = GoogleAuthProvider.credential(
                    accessToken: gAuth.accessToken,
                    idToken: gAuth.idToken,
                  );
                  // finally, lets sign in
                  await FirebaseAuth.instance.signInWithCredential(credential);
                },
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 5, right: 5, top: 5, bottom: 5),
                    child: Image.asset(
                      'assets/images/google.png',
                      height: 25,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 150),
                child: Row(
                  children: [
                    Text(
                      'Not A Member?',
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => SignUpscreen());
                      },
                      child: const Text(
                        'Sign Up Now',
                        style: TextStyle(
                            color: Color.fromRGBO(42, 193, 113, 100),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'inter'),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 60,
              ),
            ],
          ),
        )
      ])),
    ));
  }
}
