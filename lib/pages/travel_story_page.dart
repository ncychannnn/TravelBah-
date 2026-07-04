import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        return Colors.green;

      case "islands":
        return Colors.blue;

      case "wildlife":
        return Colors.orange;

      case "adventure":
        return Colors.deepPurple;

      case "food":
        return Colors.red;

      case "culture":
        return Colors.brown;

      case "city":
        return Colors.teal;

      default:
        return Colors.grey;
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
  return InkWell(
    borderRadius: BorderRadius.circular(15),
    onTap: onTap,
    child: Container(
        height: 115,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            color: color,
          ),

          const SizedBox(height: 6),

          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),

const SizedBox(height: 4),

          SizedBox(
            height: 16,
            child: count != null
                ? Text(
                    "$count",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  )
                : null,
          ),
        ],
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
        top: Radius.circular(25),
      ),
    ),
    builder: (context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [

            const SizedBox(height: 12),

            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Comments",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(),

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
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: comment.profileImage.isNotEmpty
                                  ? NetworkImage(comment.profileImage)
                                  : null,
                              child: comment.profileImage.isEmpty
                                  ? const Icon(Icons.person)
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  if (comment.uid == currentUid) ...[
                                    const SizedBox(width: 8),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "You",
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                                      if (comment.uid == currentUid)
                                        PopupMenuButton<String>(
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

                                  const SizedBox(height: 6),

                                  Text(
                                    comment.comment,
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    timeago.format(comment.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
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
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              ),
              child: Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "Write a comment...",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
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
        title: const Text("Edit Comment"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Edit your comment...",
          ),
        ),
        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),

          ElevatedButton(
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
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: const [
          Icon(
            Icons.delete_outline,
            color: Colors.red,
          ),
          SizedBox(width: 10),
          Text("Delete Comment"),
        ],
      ),
      content: const Text(
        "Are you sure you want to delete this comment?\n\nThis action cannot be undone.",
      ),
      actions: [

        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
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
          icon: const Icon(Icons.delete),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const CustomBackButton(),
        title: const Text(
          "Travel Story",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
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

    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// USER
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: post.profileImage.isNotEmpty
                      ? NetworkImage(post.profileImage)
                      : null,
                  child: post.profileImage.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),

                const SizedBox(width: 12),

                Text(
                  post.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                post.imageUrl,
                width: double.infinity,
                height: 260,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            /// CATEGORY
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _getCategoryColor(post.category),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(post.category),
                    color: Colors.white,
                    size: 18,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    post.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// TITLE
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// LOCATION
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                ),

                const SizedBox(width: 6),

                Text(post.location),
              ],
            ),

            const SizedBox(height: 20),

            /// CAPTION
            Text(
              post.caption,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
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
                        ? Icons.favorite
                        : Icons.favorite_border,
                    label: "Like",
                    count: post.likesCount,
                    color: Colors.red,
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
                    icon: Icons.chat_bubble_outline,
                    label: "Comments",
                    count: post.commentsCount,
                    color: Colors.blue,
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
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        label: saved ? "Saved" : "Save",
                        color: Colors.orange,
                        onTap: () async {
                          if (saved) {
                            await firestore.removeSavedPost(
                              currentUid,
                              post.id,
                            );

                            if (mounted) {
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

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Added to wishlist ❤️",
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