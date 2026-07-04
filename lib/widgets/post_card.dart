import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String username;
  final String profileImage;
  final String imageUrl;
  final String title;
  final String location;
  final String category;
  final String caption;
  final int likes;
  final int comments;
  final VoidCallback? onTap;
  final bool showMenu;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.username,
    required this.profileImage,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.category,
    required this.caption,
    required this.likes,
    required this.comments,
    this.onTap,
    this.showMenu = false,
    this.onEdit,
    this.onDelete,
  });

  Color getCategoryColor() {
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

  IconData getCategoryIcon() {
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

  @override
  Widget build(BuildContext context) {
    final badgeColor = getCategoryColor();

    return InkWell(
    borderRadius: BorderRadius.circular(24),
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            color: Color(0x12000000),
            offset: Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// USER
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [

                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : null,
                  child: profileImage.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                if (showMenu)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "edit") {
                        onEdit?.call();
                      }

                      if (value == "delete") {
                        onDelete?.call();
                      }
                    },
                    itemBuilder: (_) => const [

                      PopupMenuItem(
                        value: "edit",
                        child: Text("Edit Post"),
                      ),

                      PopupMenuItem(
                        value: "delete",
                        child: Text("Delete Post"),
                      ),

                    ],
                  ),

              ],
            ),
          ),

          /// IMAGE
          Stack(
            children: [

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [

                      Icon(
                        getCategoryIcon(),
                        color: Colors.white,
                        size: 16,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [

                    const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 18,
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(location),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Text(
                  caption,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [

                    const Icon(
                      Icons.favorite_border,
                      color: Colors.red,
                    ),

                    const SizedBox(width: 5),

                    Text("$likes"),

                    const SizedBox(width: 25),

                    const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.blueGrey,
                    ),

                    const SizedBox(width: 5),

                    Text("$comments"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
   );
  }
}