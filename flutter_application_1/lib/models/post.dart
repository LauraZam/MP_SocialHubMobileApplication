import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String userId;
  final String username;
  final String content;
  final List<String> likedBy;
  final DateTime createdAt;
  final int likesCount;

  Post({
    required this.postId,
    required this.userId,
    required this.username,
    required this.content,
    required this.likedBy,
    required this.createdAt,
    required this.likesCount,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Post(
      postId: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      content: data['content'] ?? '',
      likedBy: List<String>.from(data['likedBy'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: data['likesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'likesCount': likesCount,
    };
  }
}