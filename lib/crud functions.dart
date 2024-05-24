// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/route_manager.dart';

import 'package:pakaar_t2/LoginPage.dart';

create(String fullname, String aboutme, int phonenumber) async {
  User? userid = FirebaseAuth.instance.currentUser;

  try {
    await FirebaseFirestore.instance
        .collection('profileusers')
        .doc(userid!.uid)
        .set({
      "createdAT": DateTime.now(),
      "FullName": fullname,
      "aboutme": aboutme,
      "phonenumber": phonenumber,
      'userid': userid.uid,
      // ignore: prefer_const_constructors
    }).then((value) => {Get.to(() => LoginPage())});
  } on FirebaseAuthException catch (e) {
    print("Error $e");
  }
}
