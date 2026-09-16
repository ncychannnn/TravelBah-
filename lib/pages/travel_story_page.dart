import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/app_colors.dart';
import '../widgets/custom_back_button.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../models/comment_model.dart';
import 'package:timeago/timeago.dart' as timeago;

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
  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUid = FirebaseAuth.instance.currentUser!.uid;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case "nature":
        return Colors.green.shade600;

      case "islands":
        return Colors.blue.shade600;

      case "wildlife":
        return Colors.orange.shade700;

      case "adventure":
        return Colors.deepPurple.shade600;

      case "food":
        return Colors.red.shade600;

      case "culture":
        return Colors.brown.shade600;

      case "city":
        return Colors.teal.shade600;

      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case "nature":
        return Icons.park;

      case "islands":
        return Icons.beach_access;

      case "wildlife":
        return Icons.pets;

      case "adventure":
        return Icons.hiking;

      case "food":
        return Icons.restaurant;

      case "culture":
        return Icons.museum;

      case "city":
        return Icons.location_city;

      default:
        return Icons.place;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    int? count,
    required Color color,
    required VoidCallback onTap,
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
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
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

void _showComments(PostModel post) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [

            const SizedBox(height: 12),

            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Comments",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.border),

            Expanded(
              child: StreamBuilder<List<CommentModel>>(
                stream: firestore.getComments(post.id),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final comments = snapshot.data!;

                  if (comments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 60,
                            color: Colors.grey,
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            "No comments yet",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Be the first to share your travel experience!",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {

                      final comment = comments[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFFF0F4FA),
                              backgroundImage: comment.profileImage.isNotEmpty
                                  ? NetworkImage(comment.profileImage)
                                  : null,
                              child: comment.profileImage.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 18,
                                      color: AppColors.textGrey,
                                    )
                                  : null,
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Row(
                                    children: [

                            Expanded(
                              child: Row(
                                children: [

                                  Flexible(
                                    child: Text(
                                      comment.username,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColors.textDark,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  if (comment.uid == currentUid) ...[
                                    const SizedBox(width: 6),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEAF4FF),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        "You",
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                                      if (comment.uid == currentUid)
                                        PopupMenuButton<String>(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.more_horiz_rounded,
                                            color: AppColors.textGrey,
                                            size: 18,
                                          ),
                                          onSelected: (value) {
                                            if (value == "edit") {
                                              _showEditCommentDialog(
                                                post,
                                                comment,
                                              );
                                            }

                                            if (value == "delete") {
                                              _showDeleteCommentDialog(
                                                post,
                                                comment,
                                              );
                                            }
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(
                                              value: "edit",
                                              child: Text("Edit"),
                                            ),
                                            PopupMenuItem(
                                              value: "delete",
                                              child: Text("Delete"),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    comment.comment,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textDark,
                                      height: 1.3,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    timeago.format(comment.createdAt),
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                  ),
                ),
              ),
              child: Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller: commentController,
                      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: "Write a comment...",
                        hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () async {

                        if (commentController.text.trim().isEmpty) return;

                        final userDoc = await FirebaseFirestore.instance
                            .collection("users")
                            .doc(currentUid)
                            .get();

                        await firestore.addComment(
                          post.id,
                          CommentModel(
                            id: FirebaseFirestore.instance
                                .collection("posts")
                                .doc()
                                .id,
                            uid: currentUid,
                            username: userDoc["name"],
                            profileImage: userDoc["profileImage"] ?? "",
                            comment: commentController.text.trim(),
                            createdAt: DateTime.now(),
                          ),
                        );

                        commentController.clear();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showEditCommentDialog(
  PostModel post,
  CommentModel comment,
) {
  final controller = TextEditingController(
    text: comment.comment,
  );

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Edit Comment",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: "Edit your comment...",
            hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textGrey,
            ),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              await firestore.editComment(
                post.id,
                comment.id,
                controller.text.trim(),
              );

              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}

void _showDeleteCommentDialog(
  PostModel post,
  CommentModel comment,
) {
  showDialog(
    context: context,
    builder: (context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: const [
          Icon(
            Icons.delete_outline_rounded,
            color: AppColors.error,
          ),
          SizedBox(width: 10),
          Text(
            "Delete Comment",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: const Text(
        "Are you sure you want to delete this comment? This action cannot be undone.",
      ),
      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textGrey,
          ),
          child: const Text("Cancel"),
        ),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            await firestore.deleteComment(
              post.id,
              comment.id,
            );

            if (mounted) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.delete_rounded, size: 18),
          label: const Text("Delete"),
        ),
      ],
    );
    },
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

      final badgeColor = _getCategoryColor(post.category);

    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// USER
            Row(
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
                    backgroundImage: post.profileImage.isNotEmpty
                        ? NetworkImage(post.profileImage)
                        : null,
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
            ),

            const SizedBox(height: 20),

            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                post.imageUrl,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            /// CATEGORY
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: badgeColor.withOpacity(0.3),
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
                    _getCategoryIcon(post.category),
                    color: badgeColor,
                    size: 14,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    post.category,
                    style: TextStyle(
                      color: badgeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// TITLE
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 8),

            /// LOCATION
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),

                const SizedBox(width: 4),

                Text(
                  post.location,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// CAPTION
            Text(
              post.caption,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            /// ACTION BUTTONS
            Row(
              children: [

            Expanded(
              child: StreamBuilder<bool>(
                stream: firestore.hasLiked(
                  post.id,
                  currentUid,
                ),
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
                      _showComments(post);
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: StreamBuilder<bool>(
                    stream: firestore.isSaved(
                      currentUid,
                      post.id,
                    ),
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
                                  content: Text(
                                    "Removed from wishlist",
                                  ),
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
                                  content: Text(
                                    "Added to wishlist",
                                  ),
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