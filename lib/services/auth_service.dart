import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _firestore
          .collection("users")
          .doc(credential.user!.uid)
          .set({
        "uid": credential.user!.uid,
        "name": name.trim(),
        "email": email.trim(),
        "profileImage": "",
        "createdAt": Timestamp.now(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}