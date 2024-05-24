import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:multiple_images_picker/multiple_images_picker.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pakaar_t2/profileprevieww.dart';

void main() {
  runApp(MaterialApp(
    home: Addservice(),
  ));
}

class Addservice extends StatefulWidget {
  const Addservice({Key? key});

  @override
  State<Addservice> createState() => _AddserviceState();
}

class _AddserviceState extends State<Addservice> {
  List<Asset>? images;
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _aboutServiceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  String _currentLocation = "";

  Future<void> loadAssets() async {
    try {
      List<Asset>? resultList = await MultipleImagesPicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images ?? [],
      );
      if (!mounted) return;
      setState(() {
        images = resultList;
      });
    } catch (e) {
      // Handle exception
      print("Error picking images: $e");
    }
  }

  Future<void> getCurrentLocationAndTranslate() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String address = '${placemark.locality}, ${placemark.country}';
        print('User Location: $address');

        setState(() {
          _currentLocation = address;
        });
      } else {
        print('No address found');
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<List<String>> uploadImagesToFirebase(List<Asset> images) async {
    List<String> imageUrls = [];

    for (Asset asset in images) {
      final byteData = await asset.getByteData();
      final buffer = byteData.buffer.asUint8List();
      final imageName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('userserviceimg/$imageName.jpg');

      try {
        await storageReference.putData(buffer);
        final imageUrl = await storageReference.getDownloadURL();
        imageUrls.add(imageUrl);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }

    return imageUrls;
  }

  Future<void> addServiceToFirestore(List<String> imageUrls) async {
    if (_serviceNameController.text.isEmpty ||
        _aboutServiceController.text.isEmpty ||
        _addressController.text.isEmpty ||
        images == null ||
        images!.isEmpty) {
      // Show error dialog...
      return;
    }

    String serviceName = _serviceNameController.text;
    String aboutService = _aboutServiceController.text;
    String businessAddress = _addressController.text;
    String phonenumber = _phonenumberController.text;

    try {
      await FirebaseFirestore.instance
          .collection('user services')
          .doc(user!.uid)
          .set({
        "createdAt": DateTime.now(),
        "serviceName": serviceName,
        "aboutService": aboutService,
        "businessAddress": businessAddress,
        'userId': user?.uid,
        'imageUrls': imageUrls,
        "location": _currentLocation,
        'phonenumber': phonenumber,
      });

      // Show success dialog...
    } catch (e) {
      print("Error adding service: $e");
      // Show error dialog...
    }
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _aboutServiceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 100, left: 20),
                        child: Text(
                          'Add Service',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontFamily: 'Epilogue',
                            fontWeight: FontWeight.w700,
                            height: 1,
                            letterSpacing: -0.64,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50, left: 30),
                        child: InkWell(
                          onTap: loadAssets,
                          child: Icon(
                            Icons.upload,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  // Display selected images in a grid
                  if (images != null)
                    SizedBox(
                      height: 200,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5, // 5 boxes in a row
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                        ),
                        itemCount: images!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return AssetThumb(
                            asset: images![index],
                            width: 300,
                            height: 200,
                          );
                        },
                      ),
                    ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
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
                          controller: _serviceNameController,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Service Name',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
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
                          controller: _addressController,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Business Address',
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
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
                          controller: _phonenumberController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Phone number',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      height: 120, // Adjust the height as needed
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
                          controller: _aboutServiceController,
                          maxLines: null, // Allow multiple lines
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'About Service',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: InkWell(
                      onTap: getCurrentLocationAndTranslate,
                      child: Row(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(width: 8),
                          Text("Get Current Location"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(_currentLocation),
                  SizedBox(height: 30),
                  InkWell(
                    onTap: () async {
                      Get.to(() => ProfilePreview(
                            userId: '',
                          ));
                      List<String> imageUrls =
                          await uploadImagesToFirebase(images!);
                      await addServiceToFirestore(imageUrls);
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
