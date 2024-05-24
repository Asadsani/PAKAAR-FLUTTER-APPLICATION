import 'package:enhanced_url_launcher/enhanced_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/route_manager.dart';
import 'package:pakaar_t2/LoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:pakaar_t2/Profilepage.dart';
import 'package:pakaar_t2/locatippage.dart';

enum _SelectedTab { home, likes, search, location, profile }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? userid = FirebaseAuth.instance.currentUser;
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  _SelectedTab _selectedTab = _SelectedTab.home;

  Stream<QuerySnapshot<Map<String, dynamic>>> getPostsStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(
      String userId) async {
    return FirebaseFirestore.instance
        .collection('profileusers')
        .doc(userId)
        .get();
  }

  Future<void> _deletePost(String postId) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userid!.uid);

      await userRef.collection('posts').doc(postId).delete(); // Delete the post

      // Also delete related replies (optional)
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('replies')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  Future<void> _deleteReply(String postId, String replyId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('replies')
          .doc(replyId)
          .delete();
    } catch (e) {
      print('Error deleting reply: $e');
    }
  }

  Future<void> _getImageFromGallery() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showPostBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) {
        String newPostContent = '';

        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newPostContent = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter your post...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: ElevatedButton(
                    onPressed: () async {
                      if (newPostContent.isNotEmpty) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('posts')
                              .add({
                            'content': newPostContent,
                            'date': Timestamp.now(),
                            'userId': userid!.uid, // Save the user's ID
                          });

                          Navigator.pop(context);
                        } catch (e) {
                          print('Error posting to Firebase: $e');
                        }
                      }
                    },
                    child: Text('Post'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReplyBottomSheet(
      BuildContext context, String postId, String originalPostUserId) {
    String replyContent = '';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  replyContent = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter your reply...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: ElevatedButton(
                    onPressed: () async {
                      if (replyContent.isNotEmpty) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('posts')
                              .doc(postId)
                              .collection('replies')
                              .add({
                            'content': replyContent,
                            'date': Timestamp.now(),
                            'userId': userid!.uid, // Save the current user's ID
                            'originalPostUserId':
                                originalPostUserId, // Save the original post's author ID
                          });

                          Navigator.pop(context);
                        } catch (e) {
                          print('Error posting reply to Firebase: $e');
                        }
                      }
                    },
                    child: Text('Post'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getReplies(String postId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('replies')
        .orderBy(
          'date',
        )
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>> getUserProfileForReply(String userId) async {
    final userProfileDoc = await FirebaseFirestore.instance
        .collection('profileusers')
        .doc(userId)
        .get();

    if (userProfileDoc.exists) {
      final userProfileData = userProfileDoc.data() as Map<String, dynamic>;
      final imageUrl = userProfileData['imageUrl'] as String?;
      final username = userProfileData['username'] as String?;

      return {
        'imageUrl': imageUrl,
        'username': username,
      };
    } else {
      return {
        'imageUrl':
            null, // You can set a default image if the user profile doesn't exist
        'username': 'Unknown User',
      };
    }
  }

  void _handleIndexChanged(int index) {
    setState(() {
      _selectedTab = _SelectedTab.values[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                color: Colors.black,
              ),
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
              Get.off(() => LoginPage());
            },
            child: Icon(
              Icons.logout,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts available.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final post = snapshot.data!.docs[index].data();
              final content = post['content'] as String?;
              final timestamp = post['date'] as Timestamp?;
              final postId = snapshot.data!.docs[index].id;
              final userId = post['userId'] as String;
              final originalPostUserId = userId;
              final userProfileFuture = getUserProfile(userId);

              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: userProfileFuture,
                builder: (context, profileSnapshot) {
                  if (profileSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (!profileSnapshot.hasData ||
                      profileSnapshot.data!.data() == null) {
                    return Center(child: Text('User profile not found.'));
                  }

                  final profileData = profileSnapshot.data!.data()!;
                  final imageUrl = profileData['imageUrl'] as String?;
                  final userName = profileData['username'] as String?;

                  return PostCard(
                    imageUrl: imageUrl ?? '',
                    content: content ?? '',
                    timestamp: timestamp?.toDate() ?? DateTime.now(),
                    postId: postId,
                    userId: userId,
                    userName: userName ?? '',
                    showReplyBottomSheet: () {
                      _showReplyBottomSheet(
                          context, postId, originalPostUserId);
                    },
                    getReplies: () {
                      return _getReplies(postId);
                    },
                    deletePost: _deletePost,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPostBottomSheet(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: DotNavigationBar(
          margin: EdgeInsets.only(left: 10, right: 10),
          currentIndex: _SelectedTab.values.indexOf(_selectedTab),
          dotIndicatorColor: Colors.white,
          unselectedItemColor: Colors.grey[300],
          splashBorderRadius: 50,
          onTap: _handleIndexChanged,
          items: [
            // Home
            DotNavigationBarItem(
              icon: Icon(Icons.home),
              selectedColor: Color(0xff73544C),
            ),

            // Likes

            // Search

            // Location
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

            // Profile
            DotNavigationBarItem(
              icon: InkWell(
                onTap: () {
                  Get.to(() => profilepage(
                        userId: '',
                      ));
                },
                child: Icon(Icons.person),
              ),
              selectedColor: Color(0xff73544C),
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String imageUrl;
  final String content;
  final DateTime timestamp;
  final String postId;
  final String userId;
  final VoidCallback showReplyBottomSheet;
  final Future<List<Map<String, dynamic>>> Function() getReplies;
  final void Function(String) deletePost;
  final String userName;

  PostCard({
    required this.deletePost,
    required this.imageUrl,
    required this.content,
    required this.timestamp,
    required this.postId,
    required this.userId,
    required this.showReplyBottomSheet,
    required this.getReplies,
    required this.userName,
  });
  Future<void> _deleteReply(String postId, String replyId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('replies')
          .doc(replyId)
          .delete();
    } catch (e) {
      print('Error deleting reply: $e');
    }
  }

  Future<Map<String, dynamic>> getUserProfileForReply(String userId) async {
    final userProfileDoc = await FirebaseFirestore.instance
        .collection('profileusers')
        .doc(userId)
        .get();

    if (userProfileDoc.exists) {
      final userProfileData = userProfileDoc.data() as Map<String, dynamic>;
      final imageUrl = userProfileData['imageUrl'] as String?;
      final username = userProfileData['username'] as String?;
      final aboutMe = userProfileData['aboutMe'] as String?;
      final phoneNumber = userProfileData['phoneNumber'] as String?;
      return {
        'imageUrl': imageUrl,
        'username': username,
        'aboutMe': aboutMe,
        'phoneNumber': phoneNumber,
      };
    } else {
      return {
        'imageUrl':
            null, // You can set a default image if the user profile doesn't exist
        'username': 'Unknown User',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('profileusers')
                .doc(userId)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              final username = userSnapshot.data?['username'] as String?;

              return ListTile(
                leading: GestureDetector(
                  onTap: () async {
                    final userProfileData =
                        await getUserProfileForReply(userId);
                    final imageUrl = userProfileData['imageUrl'] as String?;
                    final username = userProfileData['username'] as String?;
                    final aboutMe = userProfileData['aboutMe'] as String?;
                    final phoneNumber =
                        userProfileData['phoneNumber'] as String?;
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          imageUrl: imageUrl ?? '',
                          username: username ?? '',
                          aboutMe: aboutMe ?? '',
                          phoneNumber: phoneNumber ?? '',
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(imageUrl ?? ''),
                  ),
                ),

                title: Text(
                  username ?? 'Unknown User',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(timestamp.toString()), // Format this as needed
              );
            },
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(content),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Call the delete function when the button is pressed
                    deletePost(postId);
                  },
                ),
                SizedBox(width: 8),
                TextButton(
                  onPressed: showReplyBottomSheet,
                  child: Text('Reply'),
                ),
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(postId)
                .collection('replies')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Container();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Replies:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final reply = snapshot.data!.docs[index].data();
                      final replyContent = reply['content'] as String?;
                      final replyTimestamp = reply['date'] as Timestamp?;
                      final replyUserId = reply['userId'] as String;
                      final originalPostUserId =
                          reply['originalPostUserId'] as String;
                      final userProfileFuture =
                          getUserProfileForReply(replyUserId);

                      return FutureBuilder<Map<String, dynamic>>(
                        future: userProfileFuture,
                        builder: (context, userProfileSnapshot) {
                          if (userProfileSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          final userImageUrl =
                              userProfileSnapshot.data?['imageUrl'] as String?;
                          final username =
                              userProfileSnapshot.data?['username'] as String?;

                          return ReplyCard(
                            replyContent: replyContent ?? '',
                            replyTimestamp: replyTimestamp?.toDate(),
                            userImageUrl: userImageUrl,
                            username: username ?? '',
                            userId: replyUserId,
                            // ignore: avoid_types_as_parameter_names
                            originalPostUserId: originalPostUserId,
                            getUserProfileForReply: getUserProfileForReply,
                            postId: postId,
                            deleteReply: (replyId) {
                              _deleteReply(postId, replyId);
                            }, // Pass the post ID to the reply card
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}

class ReplyCard extends StatelessWidget {
  final void Function(String) deleteReply;
  final String replyContent;
  final DateTime? replyTimestamp;
  final String? userImageUrl;
  final String userId;
  final String originalPostUserId;
  final Future<Map<String, dynamic>> Function(String) getUserProfileForReply;
  final String postId; // Add postId as a parameter

  ReplyCard({
    required this.deleteReply,
    required this.replyContent,
    required this.userId,
    required this.originalPostUserId,
    this.replyTimestamp,
    this.userImageUrl,
    required String username,
    required this.getUserProfileForReply,
    required this.postId, // Include postId in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: getUserProfileForReply(userId),
            builder: (context, userProfileSnapshot) {
              if (userProfileSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              final username = userProfileSnapshot.data?['username'] as String?;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final userProfileData =
                          await getUserProfileForReply(userId);
                      final imageUrl = userProfileData['imageUrl'] as String?;
                      final username = userProfileData['username'] as String?;
                      final aboutMe = userProfileData['aboutMe'] as String?;
                      final phoneNumber =
                          userProfileData['phoneNumber'] as String?;
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            imageUrl: imageUrl ?? '',
                            username: username ?? '',
                            aboutMe: aboutMe ?? '',
                            phoneNumber: phoneNumber ?? '',
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(userImageUrl ?? ''),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          replyContent,
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Posted at: ${replyTimestamp?.toString()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 8),
          Row(
            children: [
              SizedBox(width: 48),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Reply to this...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) async {
                    if (value.isNotEmpty) {
                      try {
                        final userRef =
                            FirebaseFirestore.instance.collection('posts');
                        final replyData = {
                          'content': value,
                          'date': Timestamp.now(),
                          'userId': userId,
                          'originalPostUserId': originalPostUserId,
                        };
                        await userRef
                            .doc(
                                postId) // Use the postId passed from the parent
                            .collection('replies')
                            .add(replyData);
                      } catch (e) {
                        print('Error posting reply: $e');
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String imageUrl;
  final String username;
  final String phoneNumber;
  final String aboutMe;

  ProfilePage({
    required this.imageUrl,
    required this.username,
    required this.phoneNumber,
    required this.aboutMe,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
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
                                borderRadius: BorderRadius.circular(183 / 2),
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
                                  final Uri url =
                                      Uri(scheme: 'tel', path: phoneNumber);
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
                              padding: const EdgeInsets.only(left: 13, top: 5),
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
        ));
  }
}
