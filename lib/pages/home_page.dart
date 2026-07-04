import 'package:flutter/material.dart';

import 'explore_page.dart';
import 'community_page.dart';
import 'wishlist_page.dart';
import 'profile_page.dart';
import 'add_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

final List<Widget> pages = [
  const ExplorePage(),
  CommunityPage(),
  WishlistPage(),
  const ProfilePage(),
];

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff5A8DEE),
        elevation: 5,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 34,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddPostPage(),
            ),
          );
        },
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        elevation: 12,
        color: Colors.white,

        child: SizedBox(
          height: 72,

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              _navItem(
                Icons.home_rounded,
                "Explore",
                0,
              ),

              _navItem(
                Icons.groups_rounded,
                "Community",
                1,
              ),

              const SizedBox(width: 40),

              _navItem(
                Icons.favorite_border,
                "Wishlist",
                2,
              ),

              _navItem(
                Icons.person_outline,
                "Profile",
                3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    int index,
  ) {
    final selected = currentIndex == index;

    return InkWell(
      onTap: () => changePage(index),

      child: SizedBox(
        width: 70,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              color: selected
                  ? const Color(0xff5A8DEE)
                  : Colors.grey,
            ),

            const SizedBox(height: 3),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: selected
                    ? const Color(0xff5A8DEE)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}