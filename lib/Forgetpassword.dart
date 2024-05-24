import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:pakaar_t2/LoginPage.dart';
import 'package:pakaar_t2/SignUpscreen.dart';
import 'dart:developer';

class Forgetpassword extends StatefulWidget {
  const Forgetpassword({Key? key});
  @override
  State<Forgetpassword> createState() => _Forgetpassword();
}

class _Forgetpassword extends State<Forgetpassword> {
  TextEditingController ForgotPassword = TextEditingController();
  bool isResetLinkSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Pakaar logo

            // Login button
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Pakaar',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Epilogue',
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                      width: 100,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    // Full Name label
                    Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Text(
                            'Forget Password',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // Full Name Text Field
                    Container(
                      height: 60,
                      width: 400,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: TextField(
                          controller: ForgotPassword,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Email',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    // Login button
                    InkWell(
                      onTap: () async {
                        var forgotEmail = ForgotPassword.text.trim();

                        try {
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: forgotEmail)
                              .then((value) {
                            print("Email sent");
                            setState(() {
                              isResetLinkSent = true;
                            });
                            // Show a pop-up dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Reset Link Sent'),
                                  content: Text(
                                    'A reset link has been sent to your email, please check.',
                                  ),
                                  actions: [
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
                          });
                        } on FirebaseAuthException catch (e) {
                          print("Error $e");
                        }
                      },
                      child: Container(
                        width: 355,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                          color: const Color.fromRGBO(51, 255, 119, 100),
                        ),
                        child: Center(
                          child: Text(
                            isResetLinkSent
                                ? 'Reset Link Sent'
                                : 'Forget Password',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
