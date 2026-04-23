import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../bloc/post/post_cubit.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String currentUserId = '';
    String currentLocale = Localizations.localeOf(context).languageCode;
    if (authState is AuthSuccess) {
      currentUserId = authState.uid;
    }

    return Scaffold(
      appBar: AppBar(
        title: Lottie.asset('assets/lottie/cat.json', width: 150, height: 90),
        centerTitle: true,
      ),
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PostLoaded) {
            final posts = state.posts;

            if (posts.isEmpty) {
              return Center(child: Text("no_posts".tr()));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PostCubit>().fetchPosts();
              },
              color: AppColors.primaryBlue,
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final bool isMyPost = post.userId == currentUserId;
                  final bool hasLiked = post.likedBy.contains(currentUserId);

                  return TweenAnimationBuilder(
                    duration: Duration(
                      milliseconds: 400 + (index * 100).clamp(0, 500),
                    ),
                    curve: Curves.easeOutQuart,
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 40 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Card(
                      color: Theme.of(context).cardColor,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  post.username,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                if (isMyPost)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.deblur_rounded,
                                      color: AppColors.divider,
                                    ),
                                    onPressed: () =>
                                        _confirmDelete(context, post.postId),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            Text(
                              post.content,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    LikeButton(
                                      isLiked: hasLiked,
                                      onTap: () {
                                        context.read<PostCubit>().handleLike(
                                          post.postId,
                                          currentUserId,
                                          post.likedBy,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${post.likesCount} ${"likes".tr()}",
                                      style: TextStyle(
                                        color: hasLiked
                                            ? Theme.of(
                                                context,
                                              ).textTheme.bodyLarge?.color
                                            : Colors.grey,
                                        fontWeight: hasLiked
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),

                                Text(
                                  DateFormat(
                                    'MMM d, HH:mm',
                                    currentLocale,
                                  ).format(post.createdAt),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return Center(child: Text("something_wrong".tr()));
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("delete_post_title".tr()),
        content: Text("delete_post_msg".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr()),
          ),
          TextButton(
            onPressed: () {
              context.read<PostCubit>().removePost(postId);
              Navigator.pop(context);
            },
            child: Text(
              "delete".tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class LikeButton extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onTap;

  const LikeButton({super.key, required this.isLiked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 150),
        tween: Tween<double>(begin: 1.0, end: isLiked ? 1.0 : 1.0),
        curve: Curves.easeOutBack,
        builder: (context, double scale, child) {
          return Transform.scale(
            scale: scale,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.grey.shade400,
                key: ValueKey<bool>(isLiked),
                size: 28,
              ),
            ),
          );
        },
      ),
    );
  }
}
