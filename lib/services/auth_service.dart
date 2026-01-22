import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static bool isLoading = false;

  static Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((credential) async {
            return await credential.user?.updateDisplayName(name);
          });
      return true;
    } on FirebaseException catch (e) {
      debugPrint("${e.message}");
      return false;
    } finally {
      isLoading = false;
    }
  }

  static Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseException catch (e) {
      debugPrint("${e.message}");
      return false;
    } finally {
      isLoading = false;
    }
  }
}
