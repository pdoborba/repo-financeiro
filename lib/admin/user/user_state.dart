import 'package:equatable/equatable.dart';

import 'user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoadInProgress extends UserState {}

class UserLoadSuccess extends UserState {
  final List<User> users;

  const UserLoadSuccess(this.users);

  @override
  String toString() {
    return 'users: $users';
  }

  @override
  List<Object?> get props => [users];
}

class UserLoadFailure extends UserState {}
