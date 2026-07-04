import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../widgets/post_card.dart';
import 'travel_story_page.dart';
import 'add_post_page.dart';

class CommunityPage extends StatelessWidget {
  CommunityPage({super.key});

  final FirestoreService firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final currentUid =
        FirebaseAuth.instance.currentUser!.uid;

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
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              const Text(
                "Discover travel experiences shared by our community.",
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("posts")
                      .orderBy(
                        "createdAt",
                        descending: true,
                      )
                      .snapshots(),

                  builder: (context, snapshot) {

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No community posts yet.",
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount:
                          snapshot.data!.docs.length,

                      itemBuilder:
                          (context, index) {

                        final doc =
                            snapshot.data!.docs[index];

                        final post =
                            PostModel.fromMap(
                          doc.data()
                              as Map<String, dynamic>,
                          doc.id,
                        );

                        return PostCard(
                          username: post.username,
                          profileImage:
                              post.profileImage,
                          imageUrl: post.imageUrl,
                          title: post.title,
                          location: post.location,
                          category: post.category,
                          caption: post.caption,
                          likes: post.likesCount,
                          comments:
                              post.commentsCount,

                          showMenu:
                              post.uid ==
                                  currentUid,

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TravelStoryPage(
                                  post: post,
                                ),
                              ),
                            );
                          },

                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddPostPage(
                                  editingPost: post,
                                ),
                              )
                            );
                          },

                          onDelete: () {

                            showDialog(
                              context: context,
                              builder: (_) =>
                                  AlertDialog(
                                title: const Text(
                                  "Delete Post",
                                ),
                                content:
                                    const Text(
                                  "Are you sure you want to delete this post?",
                                ),
                                actions: [

                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context);
                                    },
                                    child:
                                        const Text(
                                      "Cancel",
                                    ),
                                  ),

                                  ElevatedButton(
                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      backgroundColor:
                                          Colors.red,
                                    ),
                                    onPressed:
                                        () async {

                                      Navigator.pop(
                                          context);

                                      await firestore
                                          .deletePost(
                                        post.id,
                                      );

                                      ScaffoldMessenger.of(
                                              context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text(
                                            "Post deleted successfully.",
                                          ),
                                        ),
                                      );
                                    },
                                    child:
                                        const Text(
                                      "Delete",
                                    ),
                                  ),
                                ],
                              ),
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