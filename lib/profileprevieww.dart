import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:enhanced_url_launcher/enhanced_url_launcher.dart';
import 'package:get/route_manager.dart';
import 'package:pakaar_t2/HomeScreen.dart';

class ProfilePreview extends StatefulWidget {
  const ProfilePreview({super.key, required String userId});

  @override
  State<ProfilePreview> createState() => _ProfilePreviewState();
}

class _ProfilePreviewState extends State<ProfilePreview> {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference servicesCollection =
      FirebaseFirestore.instance.collection('user services');

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      // If the user is not authenticated, you can handle it here.
      // For example, show a login screen or do something else.
      return Scaffold(
        body: Center(
          child: Text('User not authenticated'),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: servicesCollection
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available.'));
          }

          final documents = snapshot.data!.docs;

          // Print the retrieved data to the console for debugging
          print("Data from Firestore: ${documents[0].data()}");

          // Assuming your Firestore document fields are named 'phoneNumber' and 'location'
          final phoneNumber = documents[0]['phonenumber'] ?? '';
          final location = documents[0]['location'] ?? '';
          final imageUrlList = documents[0]['imageUrls'] as List<dynamic>?;

          return Stack(
            children: [
              ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final data = documents[index].data() as Map<String, dynamic>;
                  final serviceName = data['serviceName'] ?? '';
                  final businessAddress = data['businessAddress'] ?? '';
                  final aboutService = data['aboutService'] ?? '';

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: InkWell(
                                onTap: () async {
                                  final Uri url =
                                      Uri(scheme: 'tel', path: phoneNumber);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    print('Cannot launch this URL');
                                  }
                                },
                                child: Icon(Icons.phone),
                              ),
                              onPressed: () {
                                // Add your phone call action here
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              'Service',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 32,
                                fontFamily: 'Epilogue',
                                fontWeight: FontWeight.w700,
                                height: 1,
                                letterSpacing: -0.64,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 40),
                      Container(
                        width: 183,
                        height: 183,
                        decoration: ShapeDecoration(
                          image: imageUrlList != null && imageUrlList.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(imageUrlList[0]),
                                  fit: BoxFit.fill,
                                )
                              : null,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 2,
                              color: Color(0xFF32FF77),
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(183 / 2),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final imageUrl in imageUrlList ?? [])
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  imageUrl,
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 50),
                            child: Text(
                              'Service  ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 70,
                        width: 400,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, top: 20),
                          child: Text(
                            serviceName,
                            style: TextStyle(
                                color: Color.fromRGBO(33, 34, 31, 0.808)),
                          ),
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2),
                            borderRadius: BorderRadius.circular(11)),
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 50),
                            child: Text(
                              'Address ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 70,
                        width: 400,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, top: 20),
                          child: Text(
                            businessAddress,
                            style: TextStyle(
                                color: Color.fromRGBO(33, 34, 31, 0.808)),
                          ),
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2),
                            borderRadius: BorderRadius.circular(11)),
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 50),
                            child: Text(
                              'About Service ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 150,
                        width: 400,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, top: 20),
                          child: Text(
                            aboutService,
                            style: TextStyle(
                                color: Color.fromRGBO(33, 34, 31, 0.808)),
                          ),
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2),
                            borderRadius: BorderRadius.circular(11)),
                      ),
                      SizedBox(height: 25),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 50),
                            child: Text(
                              'Location ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 70,
                        width: 400,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, top: 20),
                          child: Text(
                            location,
                            style: TextStyle(
                                color: Color.fromRGBO(33, 34, 31, 0.808)),
                          ),
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2),
                            borderRadius: BorderRadius.circular(11)),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      InkWell(
                        onTap: () {
                          Get.to(() => HomeScreen());
                        },
                        child: Container(
                          width: 100,
                          height: 75,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(50),
                            ),
                            color: Color.fromRGBO(51, 255, 119, 100),
                          ),
                          child: Center(
                            child: Text(
                              'Next',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
