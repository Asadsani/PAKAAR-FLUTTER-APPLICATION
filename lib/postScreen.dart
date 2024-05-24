// TODO Implement this library.import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:get/route_manager.dart';

import 'HomeScreen.dart';

class postScreen extends StatefulWidget {
  const postScreen({super.key});

  @override
  State<postScreen> createState() => _postScreenState();
}

// ignore: camel_case_types
class _postScreenState extends State<postScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  TextEditingController textController = TextEditingController();
  TextEditingController commentscontroller = TextEditingController();
  User? userid = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Text(
              "Pakaar",
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          //post message
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
//textfield
                Expanded(
                    child: TextField(
                  controller: textController,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'write something '),
                  obscureText: false,
                )),
//post button
                IconButton(
                    onPressed: () async {
                      var comments = textController.text.trim();

                      FirebaseFirestore.instance.collection('Comments').add({
                        'Comments': comments,
                        'Commentuser': currentUser.email,
                      });
                      print("comment uploaded");
                      textController.clear();
                      // ignore: prefer_const_constructors
                      Get.to(() => HomeScreen());
                    },
                    icon: const Icon(Icons.arrow_circle_up)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
