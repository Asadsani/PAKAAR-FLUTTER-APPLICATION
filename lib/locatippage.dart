import 'package:enhanced_url_launcher/enhanced_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/route_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Grid',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LocationPage(userId: 'sampleUserId'),
    );
  }
}

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key, required String userId}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  int _selectedIndex = 0; // Index for the selected tab
  final CollectionReference userServicesCollection =
      FirebaseFirestore.instance.collection('user services');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Services'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by service name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: userServicesCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No data available.'));
                }

                final documents = snapshot.data!.docs;

                // Filter users based on the search query
                final filteredDocuments = documents.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final serviceName = data['serviceName'] ?? '';
                  final businessAddress = data['businessAddress'] ?? '';
                  return serviceName.toLowerCase().contains(_searchQuery) ||
                      businessAddress.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredDocuments.isEmpty) {
                  return Center(child: Text('No matching users found.'));
                }

                return ListView.builder(
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    final data =
                        filteredDocuments[index].data() as Map<String, dynamic>;
                    final phoneNumber = data['phonenumber'] ?? '';
                    final location = data['location'] ?? '';
                    final imageUrlList = data['imageUrls'] as List<dynamic>?;
                    final serviceName = data['serviceName'] ?? '';
                    final businessAddress = data['businessAddress'] ?? '';
                    final aboutService = data['aboutService'] ?? '';

                    String imageUrl = 'https://via.placeholder.com/132x169';

                    if (imageUrlList != null && imageUrlList.isNotEmpty) {
                      imageUrl = imageUrlList[0];
                    }

                    return GestureDetector(
                      onTap: () {
                        // Navigate to the ProfilePreview page with the selected user's data
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfilePreview(
                              phoneNumber: phoneNumber,
                              location: location,
                              imageUrlList: imageUrlList,
                              serviceName: serviceName,
                              businessAddress: businessAddress,
                              aboutService: aboutService,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: 169,
                              fit: BoxFit.cover,
                            ),
                            ListTile(
                              title: Text(serviceName),
                              subtitle: Text(businessAddress),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ProfilePreview extends StatelessWidget {
  final String phoneNumber;
  final String location;
  final List<dynamic>? imageUrlList;
  final String serviceName;
  final String businessAddress;
  final String aboutService;

  ProfilePreview({
    required this.phoneNumber,
    required this.location,
    required this.imageUrlList,
    required this.serviceName,
    required this.businessAddress,
    required this.aboutService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Preview'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: InkWell(
                        onTap: () async {
                          final Uri url = Uri(scheme: 'tel', path: phoneNumber);
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
                  image: imageUrlList != null && imageUrlList!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrlList?[0]),
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
                    style: TextStyle(color: Color.fromRGBO(33, 34, 31, 0.808)),
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
                    style: TextStyle(color: Color.fromRGBO(33, 34, 31, 0.808)),
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
                    style: TextStyle(color: Color.fromRGBO(33, 34, 31, 0.808)),
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
                    style: TextStyle(color: Color.fromRGBO(33, 34, 31, 0.808)),
                  ),
                ),
                decoration: BoxDecoration(
                    border: Border.all(width: 2),
                    borderRadius: BorderRadius.circular(11)),
              ),
              SizedBox(
                height: 40,
              ),
              GestureDetector(
                onTap: () {},
                child: InkWell(
                  onTap: () {
                    // Navigate to the next screen
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
