/*
Auth States
*/

import '../../domain/models/app_user.dart';

abstract class AuthState {}

//intial
class AuthInitial extends AuthState {}

//loading..
class AuthLoading extends AuthState {}

// authenticator
class Authenticated extends AuthState {
  final AppUser user;
  Authenticated(this.user);
}

//unathenticated
class UnAuthenticated extends AuthState {}

// errors..
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}