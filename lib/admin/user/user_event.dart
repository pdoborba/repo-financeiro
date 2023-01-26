import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
}

class UserLoad extends UserEvent {
  const UserLoad();

  @override
  List<Object?> get props => [];
}
