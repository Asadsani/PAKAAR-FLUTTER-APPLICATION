import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagingPage extends StatefulWidget {
  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  late String _userId;
  late String _userImageUrl;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _userId = _user!.uid;

    // Get user image URL from Firestore
    _firestore.collection('profileusers').doc(_userId).get().then((snapshot) {
      if (snapshot.exists) {
        _userImageUrl = snapshot.get('imageUrl');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messaging App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('users')
                  .doc(_userId)
                  .collection('posts')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data?.docs;

                return ListView.builder(
                  reverse: true, // Start from the latest message
                  itemCount: messages?.length,
                  itemBuilder: (context, index) {
                    var message = messages?[index];
                    var content = message?['content'];
                    var date = message?['date']?.toDate();
                    return MessageBubble(
                      content: content,
                      date: date,
                      isMe: message?['userid'] == _userId,
                      imageUrl: _userImageUrl,
                    );
                  },
                );
              },
            ),
          ),
          MessageInput(
            onSendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    _firestore
        .collection('users')
        .doc(_userId)
        .collection('posts')
        .add({
          'content': text,
          'date': Timestamp.now(),
          'userid': _userId,
        })
        .then((_) {})
        .catchError((error) {
          print("Error sending message: $error");
        });
  }
}

class MessageBubble extends StatelessWidget {
  final String content;
  final DateTime? date;
  final bool isMe;
  final String imageUrl;

  MessageBubble({
    required this.content,
    this.date,
    required this.isMe,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isMe
                ? SizedBox.shrink()
                : CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
            Text(
              content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              date != null ? date.toString() : '',
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;

  MessageInput({required this.onSendMessage});

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final messageText = _controller.text;
    if (messageText.isNotEmpty) {
      widget.onSendMessage(messageText);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Type your message...',
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: _sendMessage,
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MessagingPage(),
  ));
}
