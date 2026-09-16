import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../widgets/comment_sheet.dart';
import '../widgets/post_card.dart';
import 'travel_story_page.dart';

class WishlistPage extends StatelessWidget {
  WishlistPage({super.key});

  final FirestoreService firestore = FirestoreService();

  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Saved",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: firestore.getWishlistPosts(currentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Something went wrong.\n${snapshot.error}",
                style: const TextStyle(color: AppColors.textDark),
              ),
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.bookmark_outline_rounded,
                      size: 64,
                      color: AppColors.textGrey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Nothing saved yet",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Save travel stories to view them here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return StreamBuilder<bool>(
                stream: FirebaseFirestore.instance
                    .collection("posts")
                    .doc(post.id)
                    .collection("likes")
                    .doc(currentUid)
                    .snapshots()
                    .map((d) => d.exists),
                builder: (context, likedSnap) {
                  // Saved page posts are always saved=true
                  final isLiked = likedSnap.data ?? false;

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
                    isSaved: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TravelStoryPage(post: post),
                        ),
                      );
                    },
                    onLike: () async {
                      await firestore.toggleLike(post.id, currentUid);
                    },
                    onComment: () {
                      showCommentSheet(context, post);
                    },
                    onSave: () async {
                      await firestore.removeSavedPost(currentUid, post.id);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}