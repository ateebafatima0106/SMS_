// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/authController.dart';
import 'package:school_management_system/dashboard/student_dashboard.dart';
import 'package:school_management_system/authentication_screens/signup_screen.dart';


class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool rememberMe = false;
  bool isPasswordVisible = false;

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.school,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sign in to continue",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // USERNAME FIELD
                    TextField(
                      controller: username,
                      decoration: InputDecoration(
                        labelText: "Username",
                        prefixIcon: Icon(Icons.person_outline,
                            color: Theme.of(context).colorScheme.primary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // PASSWORD FIELD
                    TextField(
                      controller: password,
                      obscureText: !isPasswordVisible,
                      obscuringCharacter: "•",
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock_outline,
                            color: Theme.of(context).colorScheme.primary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                            authController.rememberMe.value = rememberMe;
                          },
                        ),
                        const Text("Remember me"),
                        const Spacer(),
                      /* TextButton(
                          onPressed: () {},
                          child: const Text("Forgot Password?"),
                        ),*/
                      ],
                    ),
                    const SizedBox(height: 24),

                    // LOGIN BUTTON
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authController.isLoading.value
                                ? null
                                : () async {
                                    final username_ =
                                        username.text.trim();
                                    final password_ =
                                        password.text.trim();

                                    if (username_.isEmpty ||
                                        password_.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                              "Please complete all required fields."),
                                          backgroundColor:
                                              Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                        ),
                                      );
                                      return;
                                    }

                                    bool success =
                                        await authController.login(
                                            username_, password_);

                                    if (success) {
                                      username.clear();
                                      password.clear();

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const StudentDashboard(),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              authController.errorMessage.value),
                                          backgroundColor:
                                              Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                        ),
                                      );
                                    }
                                  },
                            child: authController.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Login",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                          ),
                        )),

                    const SizedBox(height: 24),
  /*
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                           /* Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SignupScreen(),
                              ),
                            );*/
                          },
                          child: const Text("Sign Up"),
                        ),
                      ],
                    ),*/
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