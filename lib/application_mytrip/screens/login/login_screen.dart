// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/application_mytrip/auth.dart';
import 'package:my_trip/application_mytrip/screens/login/signup_screen.dart';
import 'package:my_trip/style/appbar.dart';
import 'package:my_trip/style/background_mytrip.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBarMyTrip(
        title: 'login'.tr(),
      ),
      body: BackgroundMyTrip(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/image/mytrip-logo.png',
                      width: 350,
                      height: 350,
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'email'.tr(),
                        hintText: 'enter_your_email'.tr(),
                        fillColor: Colors.grey[100],
                        filled: true,
                        alignLabelWithHint: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 20,
                        ),
                      ),
                      controller: emailController,
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            !value.contains('@')) {
                          return 'please_enter_a_valid_email'.tr();
                        }
                        return null;
                      },
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'password'.tr(),
                        hintText: 'enter_the_password'.tr(),
                        fillColor: Colors.grey[100],
                        filled: true,
                        alignLabelWithHint: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 20,
                        ),
                        suffixIcon: SizedBox(
                          width: 24.0,
                          child: Align(
                            child: IconButton(
                              iconSize: 15,
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: isPasswordVisible
                                    ? const Color.fromARGB(255, 82, 177, 255)
                                    : const Color.fromARGB(255, 126, 126, 132),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'please_enter_your_password_correctly'.tr();
                        }
                        return null;
                      },
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isUploading)
                      const CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    if (!isUploading)
                      ElevatedButton(
                        onPressed: submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(20),
                        ),
                        child: Text('login'.tr()),
                      ),
                    if (!isUploading)
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        child: Text(
                          'i_don_net_have_an_account'.tr(),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 78, 116, 255),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuth firebase = FirebaseAuth.instance;
  bool islogin = false;
  bool isPasswordVisible = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isUploading = false;

  void submit() async {
    final valid = formKey.currentState!.validate();
    if (!valid) {
      return;
    }
    try {
      setState(() {
        isUploading = true;
      });
      await firebase.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Auth()),
        (Route<dynamic> route) => false,
      );

      setState(() {
        isUploading = false;
      });
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 38, 35, 35),
          title: Text(
            'error'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          content: Text(
            'a_verification_error_occurred'.tr(),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 83, 0, 0),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'good'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      );
    }
  }
}
