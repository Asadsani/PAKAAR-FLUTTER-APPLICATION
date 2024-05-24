class Post {
  final String id;
  final String userId;
  final String content;
  final List<String> replies;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.replies,
  });
}
