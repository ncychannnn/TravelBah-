import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool hidePassword;

  @override
  void initState() {
    super.initState();
    hidePassword = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: hidePassword,
        validator: widget.validator,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 15,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: AppColors.primary,
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}