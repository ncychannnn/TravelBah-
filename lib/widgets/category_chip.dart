import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (!isSelected)
              Icon(
                icon,
                size: 18,
                color: AppColors.primary,
              ),

            if (!isSelected)
              const SizedBox(width: 8),

            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}