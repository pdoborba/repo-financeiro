import 'package:equatable/equatable.dart';

import 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class AuthNext extends AuthEvent {
  final AuthType? type;

  const AuthNext({
    required this.type,
  });

  @override
  List<Object?> get props => [type];

  @override
  String toString() => 'AuthNext { type: $type }';
}

class SendSms extends AuthEvent {
  final String phone;

  const SendSms({
    required this.phone,
  });

  @override
  List<Object> get props => [phone];

  @override
  String toString() => 'SendSms { phone: $phone }';
}

class ValidateSms extends AuthEvent {
  final String sms;
  final String? verificationId;

  const ValidateSms({
    required this.sms,
    required this.verificationId,
  });

  @override
  List<Object?> get props => [sms, verificationId];

  @override
  String toString() =>
      'ValidateSms {  sms: $sms; verificationId: $verificationId }';
}

class Logout extends AuthEvent {
  @override
  List<Object> get props => [];
}

class Reset extends AuthEvent {
  @override
  List<Object> get props => [];
}

class SmsSent extends AuthEvent {
  final String verificationId;

  const SmsSent({
    required this.verificationId,
  });

  @override
  List<Object> get props => [verificationId];

  @override
  String toString() => 'SmsSent { verificationId: $verificationId }';
}

class CheckLogin extends AuthEvent {
  @override
  List<Object> get props => [];
}

class EmailPasswordLogin extends AuthEvent {
  final String email;
  final String password;

  const EmailPasswordLogin(this.email, this.password);

  @override
  List<Object?> get props => [email, password];

  @override
  String toString() {
    return 'EmailPasswordLogin email: $email, password: $password';
  }
}

class ForgotPassword extends AuthEvent {
  final String email;

  const ForgotPassword(this.email);

  @override
  List<Object?> get props => [email];

  @override
  String toString() {
    return 'ForgotPassword email: $email';
  }
}

class GoogleLogin extends AuthEvent {
  @override
  List<Object> get props => [];
}

class AppleLogin extends AuthEvent {
  @override
  List<Object> get props => [];
}

class RegisterUser extends AuthEvent {
  final String name;
  final String email;
  final String phone;

  const RegisterUser(
    this.name,
    this.email,
    this.phone,
  );

  @override
  List<Object?> get props => [name, email, phone];

  @override
  String toString() {
    return 'RegisterUser name: $name, email: $email, phone: $phone';
  }
}

class UpdateUser extends AuthEvent {
  final String id;
  final String name;
  final String email;
  final String phone;

  const UpdateUser(
    this.id,
    this.name,
    this.email,
    this.phone,
  );

  @override
  List<Object?> get props => [id, name, email, phone];

  @override
  String toString() {
    return 'RegisterUser id: $id, name: $name, email: $email, phone: $phone';
  }
}
