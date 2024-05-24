import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentPage extends StatefulWidget {
  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController commentController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference comments =
      FirebaseFirestore.instance.collection('comments');

  @override
  void initState() {
    super.initState();
  }

  void postComment() {
    final String commentText = commentController.text.trim();
    if (commentText.isNotEmpty) {
      comments.add({
        'content': commentText,
        'userId': 'user123', // Replace with the current user's ID
        'timestamp': FieldValue.serverTimestamp(),
      });
      commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: comments.orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final comments = snapshot.data?.docs;
                List<Widget> commentWidgets = [];
                for (var comment in comments!) {
                  final commentContent = comment['content'] ?? '';
                  final commentUserId = comment['userId'] ?? '';
                  final timestamp =
                      comment['timestamp']?.toDate() ?? DateTime.now();
                  final commentId = comment.id;

                  commentWidgets.add(
                    CommentTile(
                      commentContent: commentContent,
                      commentUserId: commentUserId,
                      timestamp: timestamp,
                      commentId: commentId,
                    ),
                  );
                }
                return ListView(
                  children: commentWidgets,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  final String commentContent;
  final String commentUserId;
  final DateTime timestamp;
  final String commentId;

  CommentTile({
    required this.commentContent,
    required this.commentUserId,
    required this.timestamp,
    required this.commentId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(commentContent),
          subtitle: Text('Posted by $commentUserId on $timestamp'),
          trailing: ElevatedButton(
            onPressed: () {
              _showReplyDialog(context, commentId);
            },
            child: Text('Reply'),
          ),
        ),
        // Display replies here
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('replies')
              .where('parentId', isEqualTo: commentId)
              .orderBy('timestamp')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox.shrink();
            }
            final replies = snapshot.data?.docs;
            List<Widget> replyWidgets = [];
            for (var reply in replies!) {
              final replyContent = reply['content'] ?? '';
              final replyUserId = reply['userId'] ?? '';
              final replyTimestamp =
                  reply['timestamp']?.toDate() ?? DateTime.now();

              replyWidgets.add(
                ListTile(
                  title: Text(replyContent),
                  subtitle: Text('Replied by $replyUserId on $replyTimestamp'),
                ),
              );
            }
            return Column(
              children: replyWidgets,
            );
          },
        ),
      ],
    );
  }

  void _showReplyDialog(BuildContext context, String parentCommentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reply to Comment'),
          content: TextField(
            decoration: InputDecoration(
              hintText: 'Your reply...',
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                FirebaseFirestore.instance.collection('replies').add({
                  'content': value,
                  'userId': 'user123', // Replace with the current user's ID
                  'timestamp': FieldValue.serverTimestamp(),
                  'parentId': parentCommentId,
                });
                Navigator.of(context).pop();
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Reply'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
