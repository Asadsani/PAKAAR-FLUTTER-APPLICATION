import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'HomeScreen.dart';

class UserProfilePage extends StatefulWidget {
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  TextEditingController fullnameController = TextEditingController();
  TextEditingController aboutmeController = TextEditingController();
  TextEditingController phonenumbercontroller = TextEditingController();
  User? userid = FirebaseAuth.instance.currentUser;
  File? pickedImage;
  bool showspinner = false;
  final _formKey = GlobalKey<FormState>(); // Added form key for validation

  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('profileImages/$imageName.jpg');
      final UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
      String imageUrl = await storageSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<void> imagePickerOption() async {
    await Get.bottomSheet(
      SingleChildScrollView(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          child: Container(
            color: Colors.white,
            height: 250,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Pick Image From",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      pickImage(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text("CAMERA"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      pickImage(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("GALLERY"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("CANCEL"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  pickImage(ImageSource imageType) async {
    try {
      final photo = await ImagePicker().pickImage(source: imageType);
      if (photo == null) return;
      final tempImage = File(photo.path);
      setState(() {
        pickedImage = tempImage;
      });

      Get.back();
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showspinner,
        child: Form(
          key: _formKey, // Add the form key to the Form widget
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ),
                            child: ClipOval(
                              child: pickedImage != null
                                  ? Image.file(
                                      pickedImage!,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      'https://cdn-icons-png.flaticon.com/512/428/428933.png',
                                      width: 170,
                                      height: 170,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    InkWell(
                      onTap: imagePickerOption,
                      child: Container(
                        width: 150,
                        height: 50,
                        padding: EdgeInsets.all(10),
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
                            'Add photo',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    buildTextField(
                      label: 'username',
                      controller: fullnameController,
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    buildTextField(
                      label: 'About Yourself',
                      controller: aboutmeController,
                      keyboardType: TextInputType.multiline,
                      minLines: 2,
                      maxLines: 5,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SingleChildScrollView(
                      child: buildTextField(
                        label: 'Phone Number',
                        controller: phonenumbercontroller,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required';
                          }
                          // Check if the phone number has at least 11 characters
                          if (value.length < 11) {
                            return 'Phone number must have at least 11 characters';
                          }
                          return null; // Return null if the input is valid
                        },
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    buildNextButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int? minLines,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 50),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'inter',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: Container(
              height: 60,
              width: 400,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 40),
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    hintText: label,
                    hintStyle: TextStyle(fontSize: 20),
                  ),
                  minLines: minLines,
                  maxLines: maxLines,
                  validator: validator, // Pass the validator function
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNextButton() {
    return SingleChildScrollView(
      child: InkWell(
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            var username = fullnameController.text.trim();
            var aboutme = aboutmeController.text.trim();
            var phonenumber = phonenumbercontroller.text.trim();
            try {
              // Upload image to Firebase Storage and get its URL
              String? imageUrl;
              if (pickedImage != null) {
                setState(() {
                  showspinner = true;
                });
                imageUrl = await uploadImageToFirebase(pickedImage!);
                setState(() {
                  showspinner = false;
                });
              }

              await FirebaseFirestore.instance
                  .collection('profileusers')
                  .doc(userid?.uid) // Use user's UID as document ID
                  .set({
                "createdAt": DateTime.now(),
                "username": username,
                "aboutMe": aboutme,
                "phoneNumber": phonenumber,
                'userId': userid?.uid,
                'imageUrl': imageUrl,
              }).then((value) {
                Get.to(() => HomeScreen());
              });
            } on FirebaseAuthException catch (e) {
              print("Error $e");
              print("Data uploaded");
            }
          }
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
