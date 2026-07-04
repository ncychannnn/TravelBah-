import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  Future<void> registerUser() async {
  if (!formKey.currentState!.validate()) return;

  if (passwordController.text != confirmPasswordController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Passwords do not match"),
      ),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    await FirebaseFirestore.instance
        .collection("users")
        .doc(userCredential.user!.uid)
        .set({
      "uid": userCredential.user!.uid,
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "profileImage": "",
      "createdAt": Timestamp.now(),
    });

// Sign out after successful registration
await FirebaseAuth.instance.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Account created successfully! Please log in.",
            ),
          ),
        );

        Navigator.pop(context);
      }
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.message ?? "Registration failed"),
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE7F1FF),
                Color(0xFFF3F8FF),
                Colors.white,
              ],
              stops: [
                0.0,
                0.45,
                1.0,
              ],
            ),
          ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Form(
                key: formKey,
                child: Column(
                  children: [

                    const SizedBox(height: 10),

                    Image.asset(
                      "assets/logo.png",
                      height: 120,
                    ),

                    const SizedBox(height: 30),

                    Text(
                      "Create Account",
                      style:
                          Theme.of(context).textTheme.headlineLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Start your journey with TravelBah!",
                      style:
                          Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 45),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 35,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(34),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 35,
                            color: Color(0x14000000),
                            offset: Offset(0, 18),
                          )
                        ],
                      ),
                      child: Column(
                        children: [

                          CustomTextField(
                            controller: nameController,
                            hintText: "Full Name",
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter your full name";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          CustomTextField(
                            controller: emailController,
                            hintText: "Email",
                            icon: Icons.email_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter your email";
                              }

                              if (!value.contains("@")) {
                                return "Please enter a valid email";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          CustomTextField(
                            controller: passwordController,
                            hintText: "Password",
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your password";
                              }

                              if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          CustomTextField(
                            controller: confirmPasswordController,
                            hintText: "Confirm Password",
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) {
                              if (value != passwordController.text) {
                                return "Password does not match";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          CustomButton(
                            title: "Register",
                            onPressed: registerUser,
                            isLoading: isLoading,
                          ),

                          const SizedBox(height: 30),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              const Text(
                                "Already have an account?",
                              ),

                              TextButton(
                                onPressed: () {
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please login with your new account."),
                                  ),
                                );
                                },
                                child: const Text(
                                  "Login",
                                ),
                              ),

                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}