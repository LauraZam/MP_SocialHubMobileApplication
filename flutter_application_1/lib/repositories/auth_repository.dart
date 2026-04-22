import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';
  static const String _keyPhone = 'user_phone';


  Future<void> saveUserData({String? name, String? email, String? phone}) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString(_keyName, name);
    if (email != null) await prefs.setString(_keyEmail, email);
    if (phone != null) await prefs.setString(_keyPhone, phone);
  }

  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName) ?? '',
      'email': prefs.getString(_keyEmail) ?? '',
      'phone': prefs.getString(_keyPhone) ?? '',
    };
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPhone);
  }


  Future<bool> register({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await saveUserData(email: email); 
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') throw 'Weak password';
      if (e.code == 'email-already-in-use') throw 'Email already in use';
      if (e.code == 'invalid-email') throw 'Invalid email';
      throw e.message ?? 'Registration error';
    } catch (e) {
      throw 'Unexpected error: $e';
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await saveUserData(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') throw 'User is not found';
      if (e.code == 'wrong-password') throw 'Wrong password';
      throw e.message ?? 'Login error';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await clearUserData();
  }
}