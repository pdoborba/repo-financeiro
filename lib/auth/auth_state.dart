import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];

  User? get user => null;

  String? get verificationId => null;
}

class AuthLoadInProgress extends AuthState {
  final num? percentage;

  const AuthLoadInProgress([this.percentage]);

  @override
  List<Object?> get props => [percentage];

  @override
  String toString() => 'AuthLoadInProgress { percentage: $percentage }';
}

class AuthLoadFailure extends AuthState {}

class AuthLoadSuccess extends AuthState {
  @override
  final User? user;

  const AuthLoadSuccess([this.user]);

  @override
  List<Object?> get props => [user];

  @override
  String toString() => 'AuthLoadSuccess { user: $user }';
}

class AuthLoadInitial extends AuthState {}

class AuthPhone extends AuthState {}

class AuthDocument extends AuthState {}

class AuthRegister extends AuthState {}

class AuthSmsSent extends AuthState {
  @override
  final String? verificationId;

  const AuthSmsSent([this.verificationId]);

  @override
  List<Object?> get props => [verificationId];

  @override
  String toString() => 'AuthSmsSent { verificationId: $verificationId }';
}
