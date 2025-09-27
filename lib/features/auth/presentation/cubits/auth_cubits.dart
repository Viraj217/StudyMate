/*
Cubits are for state management -> to show the data on the screnn
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:studymate/features/auth/domain/repos/user_repo.dart';
import 'package:studymate/features/auth/presentation/cubits/auth_states.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repos/auth_repo.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  //get current user
  AppUser? get currentUser => _currentUser;

  //check if the user is authenticated
  void checkAuth() async {
    emit(AuthLoading());

    // get current user
    // final AppUser? user = await authRepo.getCurrentUser();

    await Future.delayed(const Duration(seconds: 2));
    final user = await authRepo.getCurrentUser();

    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(UnAuthenticated());
    }
  }

  // Login with email + password
  Future<void> login(String email, String pw) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, pw);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(UnAuthenticated());
    }
  }

  //Register
  Future<void> register(String name, String email, String pw) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(name, email, pw);

      if (user != null) {
        createUser(user);
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(UnAuthenticated());
    }
  }

  //Logout
  Future<void> logout() async {
    emit(AuthLoading());
    await authRepo.logout();
    _currentUser = null;
    emit(UnAuthenticated());
  }

  //Forgot Password
  Future<String> forgotPassword(String email) async {
    try {
      emit(AuthLoading());
      final message = await authRepo.sendPasswordResetEmail(email);
      return message;
    } catch (e) {
      emit(AuthError(e.toString()));
      return e.toString();
    }
  }

  //Delete Account
  Future<void> deleteAccount() async {
    try {
      emit(AuthLoading());
      await authRepo.deleteAccount();
      _currentUser = null;
      emit(UnAuthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(UnAuthenticated());
    }
  }

  final userRepo = Get.put(UserRepo());

  Future<void> createUser(AppUser user) async {
    await userRepo.createUser(user);
    // register(user.name, user.email, user.Pass);
  }
}
