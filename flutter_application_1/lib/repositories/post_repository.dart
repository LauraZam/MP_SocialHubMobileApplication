import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Stream<List<Post>> getPostFeed() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addPost(String content, String userId, String username) async {
    await _firestore.collection('posts').add({
      'content': content,
      'userId': userId,
      'username': username,
      'likesCount': 0,
      'likedBy': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Post>> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList(),
        );
  }

  Future<void> createPost(Post post) async {
    await _firestore.collection('posts').add(post.toMap());
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  Future<void> toggleLike(
    String postId,
    String userId,
    bool isCurrentlyLiked,
  ) async {
    final postRef = _firestore.collection('posts').doc(postId);

    if (isCurrentlyLiked) {
      await postRef.update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await postRef.update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likesCount': FieldValue.increment(1),
      });
    }
  }
}
