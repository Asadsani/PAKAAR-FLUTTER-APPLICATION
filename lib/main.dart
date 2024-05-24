import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:pakaar_t2/splash_screen.dart';

import 'HomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PakaarApp());
}

class PakaarApp extends StatefulWidget {
  const PakaarApp({super.key});

  @override
  State<PakaarApp> createState() => _PakaarAppState();
}

class _PakaarAppState extends State<PakaarApp> {
  User? user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "PakaarApp",
      theme: ThemeData(primarySwatch: Colors.green),
      home: user != null ? HomeScreen() : const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
