import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../widgets/comment_sheet.dart';
import '../widgets/post_card.dart';
import 'travel_story_page.dart';
import 'add_post_page.dart';

class CommunityPage extends StatelessWidget {
  CommunityPage({super.key});

  final FirestoreService firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Community",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("posts")
                      .orderBy("createdAt", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No community posts yet.",
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final post = PostModel.fromMap(
                          doc.data() as Map<String, dynamic>,
                          doc.id,
                        );

                        return StreamBuilder<bool>(
                          stream: FirebaseFirestore.instance
                              .collection("posts")
                              .doc(post.id)
                              .collection("likes")
                              .doc(currentUid)
                              .snapshots()
                              .map((d) => d.exists),
                          builder: (context, likedSnap) {
                            return StreamBuilder<bool>(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(currentUid)
                                  .collection("wishlist")
                                  .doc(post.id)
                                  .snapshots()
                                  .map((d) => d.exists),
                              builder: (context, savedSnap) {
                                final isLiked = likedSnap.data ?? false;
                                final isSaved = savedSnap.data ?? false;

                                return PostCard(
                                  postId: post.id,
                                  username: post.username,
                                  profileImage: post.profileImage,
                                  imageUrl: post.imageUrl,
                                  title: post.title,
                                  location: post.location,
                                  category: post.category,
                                  caption: post.caption,
                                  likes: post.likesCount,
                                  comments: post.commentsCount,
                                  isLiked: isLiked,
                                  isSaved: isSaved,
                                  showMenu: post.uid == currentUid,

                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            TravelStoryPage(post: post),
                                      ),
                                    );
                                  },

                                  onLike: () async {
                                    await firestore.toggleLike(
                                      post.id,
                                      currentUid,
                                    );
                                  },

                                  onComment: () {
                                    showCommentSheet(context, post);
                                  },

                                  onSave: () async {
                                    if (isSaved) {
                                      await firestore.removeSavedPost(
                                        currentUid,
                                        post.id,
                                      );
                                    } else {
                                      await firestore.savePost(
                                        currentUid,
                                        post.id,
                                      );
                                    }
                                  },

                                  onEdit: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AddPostPage(editingPost: post),
                                      ),
                                    );
                                  },

                                  onDelete: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        title: const Text(
                                          "Delete Post",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: const Text(
                                          "Are you sure you want to delete this post? This action cannot be undone.",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  AppColors.textGrey,
                                            ),
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.error,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await firestore.deletePost(
                                                post.id,
                                              );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Post deleted successfully.",
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
