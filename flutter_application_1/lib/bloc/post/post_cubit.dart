import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/post.dart';
import '../../repositories/post_repository.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;
  PostLoaded(this.posts);
}

class PostError extends PostState {
  final String message;
  PostError(this.message);
}

class PostCubit extends Cubit<PostState> {
  final PostRepository _postRepository;

  PostCubit(this._postRepository) : super(PostInitial());

  void fetchPosts() {
    emit(PostLoading());
    _postRepository.getPostFeed().listen(
      (posts) => emit(PostLoaded(posts)),
      onError: (e) => emit(PostError(e.toString())),
    );
  }

  Future<void> addPost(Post post) async {
    try {
      await _postRepository.createPost(post);
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> removePost(String postId) async {
    try {
      await _postRepository.deletePost(postId);
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> handleLike(
    String postId,
    String userId,
    List<String> likedBy,
  ) async {
    try {
      final bool isLiked = likedBy.contains(userId);
      await _postRepository.toggleLike(postId, userId, isLiked);
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
}
