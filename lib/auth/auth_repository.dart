import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../storage/database/database_helper.dart';

class AuthRepository {
  AuthRepository();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getUser() {
    return _auth.currentUser;
  }

  Future<void> logout() async {
    await DatabaseHelper.instance.cleanDatabase();
    return FirebaseAuth.instance.signOut();
  }

  Future<User?> signInWithCredential(AuthCredential credential) async {
    return (await _auth.signInWithCredential(credential)).user;
  }

  Future<void> verifyPhoneNumber(
      String phoneNumber,
      PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
      PhoneCodeSent codeSent,
      PhoneVerificationCompleted verificationCompleted,
      PhoneVerificationFailed verificationFailed) {
    return _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        codeSent: codeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed);
  }

  Future<User?> signInWithCustomToken(String token) async {
    return (await _auth.signInWithCustomToken(token)).user;
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (_) {
      // Do nothing
    }
  }

  Future<ConfirmationResult?> signInWithPhoneNumber(String phone) async {
    try {
      return await _auth.signInWithPhoneNumber(phone);
    } catch (e) {
      return null;
    }
  }

  Future<bool> createUser(
    String email,
    String name,
    String phone,
  ) async {
    try {
      final Dio _dio = Dio();
      await _dio.post(
          'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com/prod/users',
          data: {
            'email': email,
            'name': name,
            'phone': phone,
          });
      return true;
    } on DioError catch (de) {
      print('auth_respository createUser de: ${de}');
      return false;
    } on Exception catch (e) {
      print('auth_respository createUser e: $e');
      return false;
    }
  }

  Future<bool> updateUser(
    String id,
    String email,
    String name,
    String phone,
  ) async {
    try {
      final Dio _dio = Dio();
      await _dio.put(
          'https://f0sne79mj0.execute-api.sa-east-1.amazonaws.com/prod/users',
          data: {
            'id': id,
            'email': email,
            'name': name,
            'phone': phone,
          });
      return true;
    } on DioError catch (de) {
      print('auth_respository updateUser de: ${de}');
      return false;
    } on Exception catch (e) {
      print('auth_respository updateUser e: $e');
      return false;
    }
  }
}
