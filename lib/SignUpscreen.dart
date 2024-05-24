import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pakaar_t2/LoginPage.dart';
import 'package:pakaar_t2/signUpServices.dart';

class SignUpscreen extends StatefulWidget {
  const SignUpscreen({super.key});
  @override
  State<SignUpscreen> createState() => _SignUpscreenState();
}

class _SignUpscreenState extends State<SignUpscreen> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();

  User? currentUser = FirebaseAuth.instance.currentUser;
  bool showspinner = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ModalProgressHUD(
            inAsyncCall: showspinner,
            child: SafeArea(
              child: Stack(
                children: [
                  // Pakaar logo
                  const Positioned(
                    top: 100,
                    left: 50,
                    child: Text(
                      'Pakaar',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Epilogue',
                      ),
                    ),
                  ),
                  // Login button
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 100,
                          width: 100,
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => LoginPage());
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 290,
                            ),
                            child: Container(
                              width: 100,
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(width: 2),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                              ),
                              child: const Center(
                                child: Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        // Full Name label
                        SizedBox(
                          height: 10,
                        ),
                        // Full Name Text Field
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 50),
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 40),
                            child: TextField(
                              controller: userEmailController,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Email address',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(left: 50),
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 22.0),
                            child: TextField(
                              controller: userPasswordController,
                              obscureText: true,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Password',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        // Sign Up button
                        InkWell(
                          onTap: () async {
                            var userName = userNameController.text.trim();
                            var userEmail = userEmailController.text.trim();
                            var userPassword =
                                userPasswordController.text.trim();
                            setState(() {
                              showspinner = true;
                            });

                            try {
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: userEmail,
                                password: userPassword,
                              );

                              // Sign-up successful
                              signUpUser(userName, userEmail, userPassword);
                              setState(() {
                                showspinner = false;
                              });

                              Get.to(() =>
                                  LoginPage()); // Navigate to UserProfilePage
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                showspinner = false;
                              });
                              if (e.code == 'email-already-in-use') {
                                // Email is already in use
                                errorMessage =
                                    'Email is already in use. Please use another email address.';
                              } else {
                                // Other errors
                                errorMessage =
                                    'An error occurred. Please try again later.';
                              }

                              // Show error message
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Sign Up Error'),
                                    content: Text(errorMessage),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
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
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                              color: Color.fromRGBO(51, 255, 119, 100),
                            ),
                            child: Center(
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 155),
                          child: Row(
                            children: [
                              Text(
                                'Member?',
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(() => LoginPage());
                                },
                                child: const Text(
                                  'Login Now',
                                  style: TextStyle(
                                    color: Color.fromRGBO(42, 193, 113, 100),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'inter',
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )));
  }
}
