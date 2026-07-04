import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {
  final TextEditingController emailController =
      TextEditingController();

  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>();

  bool isLoading = false;

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password reset email sent 📧",
          ),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = e.message ??
          "Something went wrong.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xffF7F8FA),
        elevation: 0,
        centerTitle: true,
        leading: const CustomBackButton(),
        title: const Text(
          "Forgot Password",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Form(
          key: formKey,

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              const Text(
                "Enter your registered email address. We'll send you a password reset link.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 35),

              CustomTextField(
                controller: emailController,
                hintText: "Email",
                icon: Icons.email_outlined,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Please enter your email";
                  }

                  if (!value.contains("@")) {
                    return "Please enter a valid email";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 35),

              CustomButton(
                title: "Send Reset Email",
                onPressed: resetPassword,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}