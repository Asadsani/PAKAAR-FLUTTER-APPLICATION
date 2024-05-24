// ignore_for_file: file_names, avoid_print, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/route_manager.dart';
import 'package:pakaar_t2/LoginPage.dart';

signUpUser(
  String userName,
  String userEmail,
  String userPassword,
) async {
  User? userid = FirebaseAuth.instance.currentUser;

  try {
    await FirebaseFirestore.instance.collection("users").doc(userid!.uid).set({
      'userEmail': userEmail,
      'createdAt': DateTime.now(),
      'userid': userid.uid,
    }).then((value) =>
        {FirebaseAuth.instance.signOut(), Get.to(() => LoginPage())});
  } on FirebaseAuthException catch (e) {
    print("Error $e");
  }
}
