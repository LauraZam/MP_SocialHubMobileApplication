import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> register({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'Weak password';
      } else if (e.code == 'email-already-in-use') {
        throw ' Email already in use';
      } else if (e.code == 'invalid-email') {
        throw 'Invalid email';
      }
      throw e.message ?? 'Registration error';
    } catch (e) {
      throw 'Unexpected error: $e';
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'User is not found';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password';
      }
      throw e.message ?? 'Login error';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
