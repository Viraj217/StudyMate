/*

AUTH REPOSITORIES - Outlines the possible auth operations for this app

 */

import '../models/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginWithEmailPassword(String email, String Password);
  Future<AppUser?> registerWithEmailPassword(String name, String Password, String pw);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
  Future<String> sendPasswordResetEmail(String email);
  Future<void> deleteAccount();
  Future<AppUser?>signInWithGoogle();
}