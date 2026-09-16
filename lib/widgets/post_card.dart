import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PostCard extends StatefulWidget {
  final String postId;
  final String username;
  final String profileImage;
  final String imageUrl;
  final String title;
  final String location;
  final String category;
  final String caption;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onSave;
  final bool showMenu;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.postId,
    required this.username,
    required this.profileImage,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.category,
    required this.caption,
    required this.likes,
    required this.comments,
    this.isLiked = false,
    this.isSaved = false,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onSave,
    this.showMenu = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  Color getCategoryColor() {
    switch (widget.category.toLowerCase()) {
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

  IconData getCategoryIcon() {
    switch (widget.category.toLowerCase()) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            color: Color(0x0A000000),
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// USER HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
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
                        backgroundImage: widget.profileImage.isNotEmpty
                            ? NetworkImage(widget.profileImage)
                            : null,
                        child: widget.profileImage.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 20,
                                color: AppColors.textGrey,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    if (widget.showMenu)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: AppColors.textGrey,
                        ),
                        onSelected: (value) {
                          if (value == "edit") widget.onEdit?.call();
                          if (value == "delete") widget.onDelete?.call();
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 28,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getCategoryIcon(),
                            color: badgeColor,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.category,
                            style: TextStyle(
                              color: badgeColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              /// DETAILS
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.location,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.caption,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 12),

                    /// ACTION ROW
                    Row(
                      children: [
                        /// LIKE
                        _ActionButton(
                          icon: widget.isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          label: "${widget.likes}",
                          color: Colors.red.shade400,
                          active: widget.isLiked,
                          onTap: widget.onLike,
                        ),
                        const SizedBox(width: 12),

                        /// COMMENT
                        _ActionButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: "${widget.comments}",
                          color: Colors.blue.shade400,
                          active: false,
                          onTap: widget.onComment,
                        ),

                        const Spacer(),

                        /// SAVE
                        _ActionButton(
                          icon: widget.isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          label: widget.isSaved ? "Saved" : "Save",
                          color: Colors.amber.shade600,
                          active: widget.isSaved,
                          onTap: widget.onSave,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? color : AppColors.textGrey,
            size: 20,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: active ? color : AppColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}