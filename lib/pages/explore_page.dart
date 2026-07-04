import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/app_colors.dart';
import '../widgets/category_chip.dart';
import '../widgets/post_card.dart';
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

  final List<String> categories = [
    "All",
    "Nature",
    "Islands",
    "Wildlife",
    "Adventure",
    "Food",
    "City",
    "Culture",
  ];

  final List<IconData> categoryIcons = [
    Icons.apps,
    Icons.park,
    Icons.beach_access,
    Icons.pets,
    Icons.landscape,
    Icons.restaurant,
    Icons.location_city,
    Icons.museum,
  ];

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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

/// ================= HEADER =================

/// LOGO
          Center(
            child: SizedBox(
              height: 70,
              child: Image.asset(
                "assets/logo.png",
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 12),

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

              final user =
                  snapshot.data!.data() as Map<String, dynamic>;

              final name =
                  user["name"] ?? "Traveler";

              final profileImage =
                  user["profileImage"] ?? "";

              return Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [

                  const SizedBox(width: 48),

                  Expanded(
                    child: Column(
                      children: [

                        Text(
                          "Hello, $name 👋",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          "Where will you explore today?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (_) => const ProfilePage(
                            showBackButton: true,
                          ),
                          ),
                        );
                      },

                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),

                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              const Color(0xffEAF4FF),

                          backgroundImage:
                              profileImage.isNotEmpty
                                  ? NetworkImage(
                                      profileImage,
                                    )
                                  : null,

                          child: profileImage.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  color:
                                      AppColors.primary,
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

          const SizedBox(height: 26),



          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
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
                            fontSize: 16,
                            color: AppColors.textDark,
                          ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),

                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(
                          left: 18,
                          right: 12,
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: Color(0xFF9AA5B1),
                          size: 26,
                        ),
                      ),

                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 56,
                        minHeight: 56,
                      ),

                      hintText: "Search destinations, places...",
                      hintStyle: const TextStyle(
                        color: Color(0xFF9AA5B1),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),

                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.tune_rounded,
                    color: Color(0xFF6B7280),
                  ),
                  tooltip: "Sort Posts",
                  onSelected: (value) {
                    setState(() {
                      selectedSort = value;
                    });
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: "newest",
                      child: Text("🕒 Newest First"),
                    ),
                    PopupMenuItem(
                      value: "oldest",
                      child: Text("🕰️ Oldest First"),
                    ),
                    PopupMenuItem(
                      value: "likes",
                      child: Text("❤️ Most Liked"),
                    ),
                    PopupMenuItem(
                      value: "comments",
                      child: Text("💬 Most Commented"),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

            Text(
              "Discover Categories",
              style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 15),

                SizedBox(
                  height: 58,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return CategoryChip(
                        title: categories[index],
                        icon: categoryIcons[index],
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

                  Text(
                    "Community Posts",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                const SizedBox(height: 15),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("posts")
                        .orderBy("createdAt", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
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
                      List<PostModel> filteredPosts =
                          snapshot.data!.docs.map((doc) {
                        return PostModel.fromMap(
                          doc.data() as Map<String, dynamic>,
                          doc.id,
                        );
                      }).toList();

                      /// Category Filter
                      if (selectedCategory != 0) {
                        final selected =
                            categories[selectedCategory].toLowerCase();

                        filteredPosts = filteredPosts.where((post) {
                          return post.category.toLowerCase() == selected;
                        }).toList();
                      }

                      /// Search
                      if (searchText.isNotEmpty) {
                        filteredPosts = filteredPosts.where((post) {
                          return post.title
                                  .toLowerCase()
                                  .contains(searchText) ||
                              post.location
                                  .toLowerCase()
                                  .contains(searchText) ||
                              post.category
                                  .toLowerCase()
                                  .contains(searchText);
                        }).toList();
                      }

                      /// Sort
                      switch (selectedSort) {
                        case "oldest":
                          filteredPosts.sort(
                            (a, b) =>
                                a.createdAt.compareTo(b.createdAt),
                          );
                          break;

                        case "likes":
                          filteredPosts.sort(
                            (a, b) =>
                                b.likesCount.compareTo(a.likesCount),
                          );
                          break;

                        case "comments":
                          filteredPosts.sort(
                            (a, b) => b.commentsCount
                                .compareTo(a.commentsCount),
                          );
                          break;

                        default:
                          filteredPosts.sort(
                            (a, b) =>
                                b.createdAt.compareTo(a.createdAt),
                          );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, index) {
                          final post = filteredPosts[index];

                          return PostCard(
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