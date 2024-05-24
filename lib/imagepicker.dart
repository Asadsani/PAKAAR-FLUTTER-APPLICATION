// import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

// class Hmscreen extends StatelessWidget {

  

//    bool showspinner = false;
//    File _image;
//   @override

//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ModalProgressHUD(
//         inAsyncCall: showspinner,
//         child: Stack(
//           children: [
//             Positioned(
//               top: 70,
//               left: 160,
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.black, width: 1),
//                   borderRadius: const BorderRadius.all(
//                     Radius.circular(100),
//                   ),
//                 ),
//                 child: ClipOval(
//                   child: pickedImage != null
//                       ? Image.file(
//                           pickedImage!,
//                           width: 150,
//                           height: 150,
//                           fit: BoxFit.cover,
//                         )
//                       : Image.network(
//                           'https://cdn-icons-png.flaticon.com/512/428/428933.png',
//                           width: 170,
//                           height: 170,
//                           fit: BoxFit.cover,
//                         ),
//                 ),
//               ),
//             ),
//             SingleChildScrollView(
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 250,
//                   ),
//                   InkWell(
//                     onTap: imagePickerOption,
//                     child: Container(
//                       width: 150,
//                       height: 50,
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: Colors.black,
//                           width: 2,
//                         ),
//                         borderRadius: const BorderRadius.all(
//                           Radius.circular(50),
//                         ),
//                         color: Color.fromRGBO(51, 255, 119, 100),
//                       ),
//                       child: Center(
//                           child: Text(
//                         'Add photo',
//                         style: TextStyle(
//                             fontSize: 15, fontWeight: FontWeight.w700),
//                       )),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 50,
//                   ),
//                   Row(
//                     children: const [
//                       Padding(
//                         padding: EdgeInsets.only(left: 50),
//                         child: Text(
//                           'Full Name ',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w500,
//                             fontFamily: 'inter',
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 16),
//                     child: Container(
//                       height: 60,
//                       width: 400,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: Colors.black,
//                           width: 2,
//                         ),
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(12)),
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.only(left: 40),
//                         child: TextField(
//                           controller: fullnameController,
//                           style: TextStyle(fontSize: 20),
//                           decoration: InputDecoration(
//                               border: InputBorder.none, hintText: 'Full Name'),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Row(
//                     children: const [
//                       Padding(
//                         padding: EdgeInsets.only(left: 50),
//                         child: Text(
//                           'About Yourself ',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w500,
//                             fontFamily: 'inter',
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 16),
//                     child: Container(
//                       height: 60,
//                       width: 400,
//                       decoration: BoxDecoration(
//                           border: Border.all(width: 2, color: Colors.black),
//                           borderRadius: BorderRadius.all(Radius.circular(12))),
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 40),
//                         child: TextFormField(
//                             controller: aboutmeController,
//                             minLines: 2,
//                             maxLines: 5,
//                             keyboardType: TextInputType.multiline,
//                             decoration: InputDecoration(
//                               hintText: "Write about yourself",
//                               hintStyle: TextStyle(fontSize: 20),
//                             )),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Row(
//                     children: const [
//                       Padding(
//                         padding: EdgeInsets.only(left: 50),
//                         child: Text(
//                           'Phone Number ',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w500,
//                             fontFamily: 'inter',
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 16),
//                     child: Container(
//                       height: 60,
//                       width: 400,
//                       decoration: BoxDecoration(
//                           border: Border.all(width: 2, color: Colors.black),
//                           borderRadius: BorderRadius.all(Radius.circular(12))),
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 40),
//                         child: TextFormField(
//                             controller: phonenumbercontroller,
//                             keyboardType: TextInputType.number,
//                             decoration: InputDecoration(
//                               hintText: "Phone Number ",
//                               hintStyle: TextStyle(fontSize: 20),
//                             )),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 50,
//                   ),
//                   InkWell(
//                     onTap: () async {
//                       final imgurl = imageupload();
//                       var fullname = fullnameController.text.trim();
//                       var aboutme = aboutmeController.text.trim();
//                       var phonenumber = phonenumbercontroller.text.trim();
//                       try {
//                         await FirebaseFirestore.instance
//                             .collection('profileusers')
//                             .doc(userid!.uid)
//                             .set({
//                           "createdAT": DateTime.now(),
//                           "FullName": fullname,
//                           "aboutme": aboutme,
//                           "phonenumber": phonenumber,
//                           'userid': userid?.uid,
//                           'imageUrl': ,
//                         }).then((value) => {
//                                   Get.to(() => HomeScreen(),
//                                       transition: Transition.zoom)
//                                 });
//                       } on FirebaseAuthException catch (e) {
//                         print("Error $e");
//                         print("data uploaded");
//                       }

//                       imageupload();
//                     },
//                     child: Container(
//                       width: 100,
//                       height: 75,
//                       padding: EdgeInsets.all(15),
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: Colors.black,
//                           width: 2,
//                         ),
//                         borderRadius: const BorderRadius.all(
//                           Radius.circular(50),
//                         ),
//                         color: Color.fromRGBO(51, 255, 119, 100),
//                       ),
//                       child: Center(
//                           child: Text(
//                         'Next',
//                         style: TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.w700),
//                       )),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }