
import 'package:assign_live_scoree_app/screens/sign_in_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameTECOntroller = .new();
  final TextEditingController _emailTECOntroller = .new();
  final TextEditingController _psswordTECOntroller = .new();
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
                Text("Sign Up", style: TextTheme.of(context).titleLarge),
                SizedBox(height: 20),
                TextFormField(
                  controller: _nameTECOntroller,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Name";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: _emailTECOntroller,
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
                  controller: _psswordTECOntroller,
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
                  onPressed: AuthService.isLoading ? null : _onTapSignUp,
                  child: AuthService.isLoading
                      ? Center(
                          child: SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Text("Sign Up"),
                ),
                SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    text: "Already have n account ?",
                    style: .new(color: Colors.black),
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInScreen(),
                              ),
                            );
                          },
                        text: "Sign In",
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

  void _onTapSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {});
      final success = await AuthService.signUp(
        name: _nameTECOntroller.text.trim(),
        email: _emailTECOntroller.text.trim(),
        password: _psswordTECOntroller.text.trim(),
      );

      setState(() {});
      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
        _nameTECOntroller.clear();
        _emailTECOntroller.clear();
        _psswordTECOntroller.clear();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("SignUp failed")));
      }
    }
  }
}
