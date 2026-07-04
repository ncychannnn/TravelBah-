import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  Future<void> loginUser() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Login Failed";

      if (e.code == "user-not-found") {
        message = "No account found.";
      } else if (e.code == "wrong-password") {
        message = "Incorrect password.";
      } else if (e.code == "invalid-email") {
        message = "Invalid email.";
      } else if (e.code == "invalid-credential") {
        message = "Email or password is incorrect.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
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
    passwordController.dispose();
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

                    const SizedBox(height: 20),

                    const Text(
                      "Welcome to\nThe Land Below the Wind 🌀",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: Color(0xFF1E3A5F), // Dark blue
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Sign in to continue your adventure.",
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

                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ForgotPasswordPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Forgot Password?",
                                  ),
                                ),
                          ),

                          const SizedBox(height: 10),

                          CustomButton(
                            title: "Login",
                            onPressed: loginUser,
                            isLoading: isLoading,
                          ),

                          const SizedBox(height: 30),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              const Text(
                                "Don't have an account?",
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const RegisterPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Register",
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