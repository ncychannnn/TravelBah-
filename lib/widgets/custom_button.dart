import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              Color(0xff78B4FF),
              Color(0xff4F8EF7),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x255A8DEE),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
        ),
      ),
    );
  }
}