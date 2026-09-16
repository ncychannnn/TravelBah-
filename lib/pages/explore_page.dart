import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/app_colors.dart';
import '../utils/category_utils.dart';
import '../widgets/category_chip.dart';
import '../widgets/comment_sheet.dart';
import '../widgets/post_card.dart';
import '../services/firestore_service.dart';
import 'profile_page.dart';
import 'travel_story_page.dart';
import '../models/post_model.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final searchController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  int selectedCategory = 0;
  String searchText = "";
  String selectedSort = "newest";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= HEADER =================

              /// LOGO
              Center(
                child: SizedBox(
                  height: 48,
                  child: Image.asset("assets/logo.png", fit: BoxFit.contain),
                ),
              ),

              const SizedBox(height: 24),

              /// GREETING + PROFILE
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final user = snapshot.data!.data() as Map<String, dynamic>;

                  final name = user["name"] ?? "Traveler";
                  final profileImage = user["profileImage"] ?? "";

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello, $name",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Where will you explore today?",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ProfilePage(showBackButton: true),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xffEAF4FF),
                              backgroundImage: profileImage.isNotEmpty
                                  ? NetworkImage(profileImage)
                                  : null,
                              child: profileImage.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: AppColors.primary,
                                      size: 22,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              /// SEARCH + SORT
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x04000000),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchText = value.trim().toLowerCase();
                          });
                        },
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: "Search destinations, places...",
                          hintStyle: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.textGrey,
                            size: 22,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<String>(
                    tooltip: "Sort Posts",
                    onSelected: (value) {
                      setState(() {
                        selectedSort = value;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: "newest",
                        child: Text("Newest First"),
                      ),
                      PopupMenuItem(
                        value: "oldest",
                        child: Text("Oldest First"),
                      ),
                      PopupMenuItem(value: "likes", child: Text("Most Liked")),
                      PopupMenuItem(
                        value: "comments",
                        child: Text("Most Commented"),
                      ),
                    ],
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x04000000),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                "Discover Categories",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: travelCategories.length,
                  itemBuilder: (context, index) {
                    final category = travelCategories[index];

                    return CategoryChip(
                      title: category.title,
                      icon: category.icon,
                      isSelected: selectedCategory == index,
                      onTap: () {
                        setState(() {
                          selectedCategory = index;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Community Posts",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 15),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("posts")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: const Column(
                        children: [
                          Icon(
                            Icons.travel_explore,
                            size: 60,
                            color: AppColors.textGrey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "No travel posts yet.\nBe the first to share your adventure!",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  /// Convert Firestore documents to PostModel
                  List<PostModel> filteredPosts = snapshot.data!.docs.map((
                    doc,
                  ) {
                    return PostModel.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );
                  }).toList();

                  /// Category Filter
                  if (selectedCategory != 0) {
                    final selected =
                        travelCategories[selectedCategory].title.toLowerCase();

                    filteredPosts = filteredPosts.where((post) {
                      return post.category.toLowerCase() == selected;
                    }).toList();
                  }

                  /// Search
                  if (searchText.isNotEmpty) {
                    filteredPosts = filteredPosts.where((post) {
                      return post.title.toLowerCase().contains(searchText) ||
                          post.location.toLowerCase().contains(searchText) ||
                          post.category.toLowerCase().contains(searchText);
                    }).toList();
                  }

                  /// Sort
                  switch (selectedSort) {
                    case "oldest":
                      filteredPosts.sort(
                        (a, b) => a.createdAt.compareTo(b.createdAt),
                      );
                      break;

                    case "likes":
                      filteredPosts.sort(
                        (a, b) => b.likesCount.compareTo(a.likesCount),
                      );
                      break;

                    case "comments":
                      filteredPosts.sort(
                        (a, b) => b.commentsCount.compareTo(a.commentsCount),
                      );
                      break;

                    default:
                      filteredPosts.sort(
                        (a, b) => b.createdAt.compareTo(a.createdAt),
                      );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];

                      return StreamBuilder<bool>(
                        stream: FirebaseFirestore.instance
                            .collection("posts")
                            .doc(post.id)
                            .collection("likes")
                            .doc(uid)
                            .snapshots()
                            .map((d) => d.exists),
                        builder: (context, likedSnap) {
                          return StreamBuilder<bool>(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .doc(uid)
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
                                  await FirestoreService()
                                      .toggleLike(post.id, uid);
                                },
                                onComment: () {
                                  showCommentSheet(context, post);
                                },
                                onSave: () async {
                                  if (isSaved) {
                                    await FirestoreService()
                                        .removeSavedPost(uid, post.id);
                                  } else {
                                    await FirestoreService()
                                        .savePost(uid, post.id);
                                  }
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
            ],
          ),
        ),
      ),
    );
  }
}
