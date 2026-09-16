import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../utils/category_utils.dart';
import '../widgets/comment_sheet.dart';
import '../widgets/custom_back_button.dart';

class TravelStoryPage extends StatefulWidget {
  final PostModel post;

  const TravelStoryPage({
    super.key,
    required this.post,
  });

  @override
  State<TravelStoryPage> createState() => _TravelStoryPageState();
}

class _TravelStoryPageState extends State<TravelStoryPage> {
  final FirestoreService firestore = FirestoreService();
  late final String currentUid;

  @override
  void initState() {
    super.initState();
    currentUid = FirebaseAuth.instance.currentUser!.uid;
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    int? count,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 4,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (count != null) ...[
                      const SizedBox(width: 3),
                      Text(
                        "($count)",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: const CustomBackButton(),
        title: const Text(
          "Travel Story",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("posts")
            .doc(widget.post.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.data!.exists) {
            return const Center(
              child: Text("Post not found"),
            );
          }

          final post = PostModel.fromMap(
            snapshot.data!.data() as Map<String, dynamic>,
            snapshot.data!.id,
          );

          final badgeColor = categoryColor(post.category);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StoryAuthor(post: post),
                const SizedBox(height: 20),
                _StoryImage(imageUrl: post.imageUrl),
                const SizedBox(height: 20),
                _CategoryBadge(
                  category: post.category,
                  color: badgeColor,
                ),
                const SizedBox(height: 16),
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                _StoryLocation(location: post.location),
                const SizedBox(height: 20),
                Text(
                  post.caption,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: StreamBuilder<bool>(
                        stream: firestore.hasLiked(post.id, currentUid),
                        builder: (context, snapshot) {
                          final liked = snapshot.data ?? false;

                          return _buildActionButton(
                            icon: liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            label: "Like",
                            count: post.likesCount,
                            color: Colors.red.shade400,
                            onTap: () async {
                              await firestore.toggleLike(
                                post.id,
                                currentUid,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: "Comments",
                        count: post.commentsCount,
                        color: Colors.blue.shade400,
                        onTap: () {
                          showCommentSheet(context, post);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StreamBuilder<bool>(
                        stream: firestore.isSaved(currentUid, post.id),
                        builder: (context, snapshot) {
                          final saved = snapshot.data ?? false;

                          return _buildActionButton(
                            icon: saved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            label: saved ? "Saved" : "Save",
                            color: Colors.orange.shade400,
                            onTap: () async {
                              if (saved) {
                                await firestore.removeSavedPost(
                                  currentUid,
                                  post.id,
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Removed from wishlist"),
                                    ),
                                  );
                                }
                              } else {
                                await firestore.savePost(
                                  currentUid,
                                  post.id,
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Added to wishlist"),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StoryAuthor extends StatelessWidget {
  final PostModel post;

  const _StoryAuthor({
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFF0F4FA),
            backgroundImage:
                post.profileImage.isNotEmpty ? NetworkImage(post.profileImage) : null,
            child: post.profileImage.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 20,
                    color: AppColors.textGrey,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          post.username,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

class _StoryImage extends StatelessWidget {
  final String imageUrl;

  const _StoryImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  final Color color;

  const _CategoryBadge({
    required this.category,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryIcon(category),
            color: color,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            category,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryLocation extends StatelessWidget {
  final String location;

  const _StoryLocation({
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_rounded,
          color: AppColors.primary,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          location,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
