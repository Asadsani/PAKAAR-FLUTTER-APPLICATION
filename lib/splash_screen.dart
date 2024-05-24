// ignore_for_file: sort_child_properties_last

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pakaar_t2/LoginPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    //this state is the initial state of app
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          )); // MaterialPageRoute
    }); // Timer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Center(
                child: Text(
              'Pakaar',
              style: TextStyle(fontSize: 64, fontWeight: FontWeight.w700),
            )),
            color: const Color.fromRGBO(51, 255, 119, 100)));
  }
}
