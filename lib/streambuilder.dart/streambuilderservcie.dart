// import 'package:cloud_firestore/cloud_firestore.dart';

// Stream<Map<String, dynamic>> getUserDataStream(String userId) {
//   return FirebaseFirestore.instance
//       .collection(
//           'profileusers') // Fetch data from the 'profileusers' collection
//       .doc(userId)
//       .snapshots()
//       .map((snapshot) {
//     final data = snapshot.data();
//     if (data == null) {
//       return {}; // Return an empty map if data is null
//     }

//     // Get data from the "userPosts" collection inside the document
//     final userPostsCollection = data['userPosts'] as List<dynamic>?;

//     // Map each post to a new map containing the "content", "userEmail", and "timestamp" fields
//     final userPostsData = userPostsCollection?.map((post) {
//       final content = post['content'] as String? ?? '';
//       final timestamp = post['date'] as Timestamp? ?? Timestamp.now();
//       return {
//         'content': content,
//       };
//     }).toList();

//     // Return the data as a map, including the 'imageUrl' from the 'profileusers' collection
//     return {
//       'userName': data['userName'] as String? ?? '',
//       'imageUrl': data['imageUrl'] as String? ?? '',
//       'posts': userPostsData,
//     };
//   });
// }
