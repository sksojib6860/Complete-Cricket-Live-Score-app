import 'package:assign_live_scoree_app/screens/sign_up_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailTEController = .new();
  final TextEditingController _passwordTEController = .new();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 10,
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                Text("Sign In", style: TextTheme.of(context).titleLarge),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailTEController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Email";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  obscureText: true,
                  controller: _passwordTEController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Password";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                FilledButton(
                  style: .new(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: .circular(10)),
                    ),
                    fixedSize: WidgetStatePropertyAll(
                      Size(double.maxFinite, 50),
                    ),
                  ),
                  onPressed: AuthService.isLoading ? null : _onTapSignIn,
                  child: AuthService.isLoading
                      ? Center(
                          child: SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Text("Sign In"),
                ),
                SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    text: "Don't have an account ?",
                    style: .new(color: Colors.black),
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ),
                            );
                          },
                        text: "Sign Up",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTapSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {});
      final success = await AuthService.signIn(
        email: _emailTEController.text.trim(),
        password: _passwordTEController.text.trim(),
      );

      setState(() {});
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              onThemeChanged: () {
                setState(() {});
              },
            ),
          ),
          (route) => false,
        );
        _emailTEController.clear();
        _passwordTEController.clear();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("SignUp failed")));
      }
    }
  }
}
