import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_back_button.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() =>
      _ChangePasswordPageState();
}

class _ChangePasswordPageState
    extends State<ChangePasswordPage> {

  final _formKey = GlobalKey<FormState>();

  final currentPasswordController =
      TextEditingController();

  final newPasswordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  Future<void> changePassword() async {

    if (!_formKey.currentState!.validate()) return;

    if (newPasswordController.text !=
        confirmPasswordController.text) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Passwords do not match.",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final user =
          FirebaseAuth.instance.currentUser!;

      final credential =
          EmailAuthProvider.credential(
        email: user.email!,
        password:
            currentPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(
        credential,
      );

      await user.updatePassword(
        newPasswordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password changed successfully 🔐",
          ),
        ),
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      String message =
          "Unable to change password.";

      if (e.code ==
          "wrong-password") {
        message =
            "Current password is incorrect.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {

    currentPasswordController.dispose();

    newPasswordController.dispose();

    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor:
          const Color(0xffF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xffF7F8FA),
        elevation: 0,
        centerTitle: true,
        leading: const CustomBackButton(),
        title: const Text(
          "Change Password",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(24),

          child: Form(

            key: _formKey,

            child: Column(

              children: [

                const SizedBox(height: 15),

                const Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Color(0xff5A8DEE),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Update your password",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Your new password must be at least 6 characters.",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 35),

                CustomTextField(
                  controller:
                      currentPasswordController,
                  hintText:
                      "Current Password",
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {

                    if (value == null ||
                        value.isEmpty) {
                      return "Please enter your current password";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  controller:
                      newPasswordController,
                  hintText:
                      "New Password",
                  icon: Icons.lock_reset,
                  obscureText: true,
                  validator: (value) {

                    if (value == null ||
                        value.isEmpty) {
                      return "Please enter your new password";
                    }

                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  controller:
                      confirmPasswordController,
                  hintText:
                      "Confirm Password",
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) {

                    if (value == null ||
                        value.isEmpty) {
                      return "Please confirm your password";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 40),
                                CustomButton(
                  title: "Save Changes",
                  onPressed: changePassword,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}