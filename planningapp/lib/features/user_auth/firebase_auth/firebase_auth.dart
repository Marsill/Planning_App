import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmailAndPassword(String username, String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user != null) {
        await user.updateDisplayName(username);
        await user.reload();

        await _firestore.collection("users").doc(user.uid).set({
          "username": username,
          "email": email,
          "phoneNumber": "", 
          "address": "",     
        });

        return user;
      }
    } catch (e) {
      print("Error occurred during sign-up: $e");
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Error occurred during log-in: $e");
    }
    return null;
  }
}
