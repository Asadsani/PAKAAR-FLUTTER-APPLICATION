import 'package:enhanced_url_launcher/enhanced_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:get/route_manager.dart';
import 'package:pakaar_t2/Addservice.dart';
import 'package:pakaar_t2/HomeScreen.dart';
import 'package:pakaar_t2/locatippage.dart';

class profilepage extends StatefulWidget {
  const profilepage({Key? key, required String userId}) : super(key: key);

  @override
  State<profilepage> createState() => _profilepageState();
}

class _profilepageState extends State<profilepage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>> getUserData(String userId) async {
    final userData = await FirebaseFirestore.instance
        .collection('profileusers')
        .doc(userId)
        .get();
    final phoneNumber = userData.data()?['phoneNumber'] as String? ?? '';
    return {
      ...userData.data() as Map<String, dynamic>,
      'phoneNumber': phoneNumber,
    };
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUser() async {
    return FirebaseFirestore.instance
        .collection('profileusers')
        .doc(currentUser!.uid)
        .get();
  }

  late final _ratingController;
  late double _rating;

  double _userRating = 3.0;
  int _ratingBarMode = 1;
  double _initialRating = 2.0;
  bool _isRTLMode = false;
  bool _isVertical = false;

  IconData? _selectedIcon;

  @override
  void initState() {
    super.initState();
    _ratingController = TextEditingController(text: '3.0');
    _rating = _initialRating;
  }

  bool hasLowRating(double rating) {
    // Define your threshold value for low ratings here
    return rating <= 2.5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 50),
            child: Text(
              "Pakaar",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: () {
              // Handle location icon tap
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data;
          final imageUrl = userData?['imageUrl'] as String? ?? '';
          final phoneNumber = userData?['phoneNumber'] as String? ?? '';

          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: getCurrentUser(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final username = userSnapshot.data?['username'] as String? ?? '';
              final aboutMe = userData?['aboutMe'] as String? ?? '';

              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 30,
                            top: 50,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 80,
                                height: 50.67,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 30.67,
                                      child: SizedBox(
                                        width: 90,
                                        height: 20,
                                        child: InkWell(
                                          onTap: () {
                                            Get.to(() => Addservice());
                                          },
                                          child: Text(
                                            'Add Service',
                                            style: TextStyle(
                                              color: Color(0xFF383737),
                                              fontSize: 11,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 20.33,
                                      top: 0,
                                      child: Container(
                                        width: 23.33,
                                        height: 20.33,
                                        child: Stack(children: [
                                          InkWell(
                                            onTap: () {
                                              Get.to(() => Addservice());
                                            },
                                            child: Icon(
                                              Icons.add,
                                              size: 40,
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 110),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 183,
                                  height: 183,
                                  decoration: ShapeDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.fill,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 2,
                                        color: Color(0xFF32FF77),
                                        style: BorderStyle.solid,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(183 / 2),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15.0),
                                SizedBox(height: 15.0),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: username + ' ',
                                        style: TextStyle(
                                          color: Color(0xFF141619),
                                          fontSize: 30.67,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.57,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' ',
                                        style: TextStyle(
                                          color: Color(0xFFFF0000),
                                          fontSize: 30.67,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.57,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Container(
                                  width: 137,
                                  height: 36,
                                  decoration: ShapeDecoration(
                                    color: Color(0xFF32FF77),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(width: 0.50),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: Center(
                                    child: InkWell(
                                      onTap: () async {
                                        final Uri url = Uri(
                                            scheme: 'tel', path: phoneNumber);
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url);
                                        } else {
                                          print('Cannot launch this URL');
                                        }
                                      },
                                      child: SizedBox(
                                        width: 73,
                                        height: 18,
                                        child: Text(
                                          'Contact',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12.15,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            height: 1,
                                            letterSpacing: -0.24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                Container(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 13, top: 5),
                                    child: SizedBox(
                                      width: 270,
                                      child: Text(
                                        aboutMe,
                                        style: TextStyle(
                                          color: Color(0xFF383737),
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                  width: 370,
                                  height: 211,
                                  decoration: ShapeDecoration(
                                    color: Color(0x6DD9D9D9),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(width: 0.50),
                                      borderRadius: BorderRadius.circular(26),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: DotNavigationBar(
          margin: EdgeInsets.only(left: 10, right: 10),
          currentIndex: 3, // Index for Profile tab
          dotIndicatorColor: Colors.white,
          unselectedItemColor: Colors.grey[300],
          splashBorderRadius: 50,
          onTap: (index) {
            // Handle navigation here
          },
          items: [
            DotNavigationBarItem(
              icon: InkWell(
                  onTap: () {
                    Get.to(() => HomeScreen(),
                        transition: Transition.leftToRight);
                  },
                  child: Icon(Icons.home)),
              selectedColor: Color(0xff73544C),
            ),
            DotNavigationBarItem(
              icon: InkWell(
                  onTap: () {
                    Get.to(() => LocationPage(
                          userId: '',
                        ));
                  },
                  child: Icon(Icons.location_on)),
              selectedColor: Color(0xff73544C),
            ),
            DotNavigationBarItem(
              icon: Icon(Icons.person),
              selectedColor: Color(0xff73544C),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image(String asset) {
    return Image.asset(
      asset,
      height: 30.0,
      width: 30.0,
      color: Colors.amber,
    );
  }
}
