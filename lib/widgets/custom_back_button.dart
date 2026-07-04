import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        top: 8,
        bottom: 8,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: const Color(0xffEAF4FF),
          elevation: 2,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xff5A8DEE),
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}