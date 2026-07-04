import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ActivityCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x12000000),
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xff5A8DEE),
            size: 28,
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}