import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../widgets/post_card.dart';
import 'travel_story_page.dart';

class WishlistPage extends StatelessWidget {
  WishlistPage({super.key});

  final FirestoreService firestore = FirestoreService();

  final String currentUid =
      FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wishlist"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: firestore.getWishlistPosts(currentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Something went wrong.\n${snapshot.error}",
              ),
            );
          }

          final posts = snapshot.data ?? [];
          debugPrint("Current UID: $currentUid");

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.bookmark_border,
                    size: 90,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No saved destinations yet",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Save travel stories to view them here.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: PostCard(
                  username: post.username,
                  profileImage: post.profileImage,
                  imageUrl: post.imageUrl,
                  title: post.title,
                  location: post.location,
                  category: post.category,
                  caption: post.caption,
                  likes: post.likesCount,
                  comments: post.commentsCount,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TravelStoryPage(
                          post: post,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}