import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import 'auth_event.dart';
import 'auth_repository.dart';
import 'auth_state.dart';

// ignore: constant_identifier_names
enum AuthType { PHONE, DOCUMENT, REGISTER }

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository? authRepository;

  ConfirmationResult? _smsConfirmation;

  AuthBloc({this.authRepository}) : super(AuthLoadInitial());

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is SendSms) {
      if (kIsWeb) {
        yield* _mapSendSmsWebToState(event.phone);
      } else {
        yield* _mapSendSmsToState(event.phone);
      }
    } else if (event is ValidateSms) {
      if (kIsWeb) {
        yield* _mapValidateSmsWebToState(event.sms);
      } else {
        yield* _mapValidateSmsToState(event.sms, event.verificationId ?? '');
      }
    } else if (event is Logout) {
      yield* _mapLogoutToState();
    } else if (event is Reset) {
      yield* _mapLogoutToState();
    } else if (event is SmsSent) {
      yield AuthSmsSent(event.verificationId);
    } else if (event is AuthNext) {
      yield* _mapNextToState(event.type);
    } else if (event is CheckLogin) {
      yield* _mapCheckLoginToState();
    } else if (event is EmailPasswordLogin) {
      yield* _mapEmailPasswordLoginToState(event.email, event.password);
    } else if (event is GoogleLogin) {
      yield* _mapGoogleLoginToState();
    } else if (event is AppleLogin) {
      yield* _mapAppleLoginToState();
    } else if (event is ForgotPassword) {
      yield* _mapForgotToState(event.email);
    } else if (event is RegisterUser) {
      yield* _mapRegisterToState(event.email, event.name, event.phone);
    } else if (event is UpdateUser) {
      yield* _mapUpdateToState(event.id, event.email, event.name, event.phone);
    }
  }

  Stream<AuthState> _mapSendSmsWebToState(String phoneNumber) async* {
    try {
      yield const AuthLoadInProgress();
      var phone = phoneNumber
          .replaceAll('(', '')
          .replaceAll(')', '')
          .replaceAll(' ', '')
          .replaceAll('-', '');
      _smsConfirmation =
          await authRepository?.signInWithPhoneNumber('+55$phone');
      add(const SmsSent(verificationId: ''));
    } on Exception catch (_) {
      await authRepository!.logout();
      yield AuthLoadFailure();
    }
  }

  Stream<AuthState> _mapSendSmsToState(String phoneNumber) async* {
    try {
      yield const AuthLoadInProgress();
      Stream<AuthState> verificationFailed(var authException) async* {
        yield AuthLoadFailure();
      }

      Stream<AuthState> verificationCompleted(var phoneAuthCredential) async* {
        var user = (await signInWithCredential(phoneAuthCredential));
        yield* _mapFinishLoginToState(user);
      }

      void codeSent(var verificationId, [var forceResendingToken]) {
        add(SmsSent(verificationId: verificationId));
      }

      void codeAutoRetrievalTimeout(var verificationId) {
        // add(Reset());
      }

      var phone = phoneNumber
          .replaceAll('(', '')
          .replaceAll(')', '')
          .replaceAll(' ', '')
          .replaceAll('-', '');

      await verifyPhoneNumber('+55$phone', codeAutoRetrievalTimeout, codeSent,
          verificationCompleted, verificationFailed);
    } on Exception catch (_) {
      await authRepository!.logout();
      yield AuthLoadFailure();
    }
  }

  Stream<AuthState> _mapFinishLoginToState(User? user) async* {
    yield const AuthLoadSuccess();
  }

  Stream<AuthState> _mapValidateSmsWebToState(String smsCode) async* {
    try {
      yield const AuthLoadInProgress();
      UserCredential? userCredential = await _smsConfirmation?.confirm(smsCode);
      if (userCredential != null && userCredential.user != null) {
        yield* _mapFinishLoginToState(userCredential.user!);
      } else {
        await authRepository!.logout();
        yield AuthLoadFailure();
      }
    } on Exception catch (e) {
      await authRepository!.logout();
      yield AuthLoadFailure();
    }
  }

  Stream<AuthState> _mapValidateSmsToState(
      String smsCode, String verificationId) async* {
    try {
      yield const AuthLoadInProgress();

      var credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);

      var user = (await signInWithCredential(credential));
      yield* _mapFinishLoginToState(user);
    } on Exception catch (_) {
      await authRepository!.logout();
      yield AuthLoadFailure();
    }
  }

  Stream<AuthState> _mapLogoutToState() async* {
    try {
      yield const AuthLoadInProgress();
      await authRepository!.logout();
      yield AuthLoadInitial();
    } on Exception catch (_) {
      yield AuthLoadFailure();
    }
  }

  Future<User?> signInWithCredential(AuthCredential credential) {
    return authRepository!.signInWithCredential(credential);
  }

  Future<void> verifyPhoneNumber(
      String phoneNumber,
      PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
      PhoneCodeSent codeSent,
      PhoneVerificationCompleted verificationCompleted,
      PhoneVerificationFailed verificationFailed) {
    return authRepository!.verifyPhoneNumber(
        phoneNumber,
        codeAutoRetrievalTimeout,
        codeSent,
        verificationCompleted,
        verificationFailed);
  }

  Stream<AuthState> _mapNextToState(AuthType? type) async* {
    try {
      switch (type) {
        case AuthType.PHONE:
          yield AuthPhone();
          break;
        case AuthType.DOCUMENT:
          yield AuthDocument();
          break;
        case AuthType.REGISTER:
          yield AuthRegister();
          break;
        default:
          yield AuthLoadFailure();
      }
    } on Exception catch (_) {
      yield AuthLoadFailure();
    }
  }

  /// Handle the current logged user
  Stream<AuthState> _mapCheckLoginToState() async* {
    try {
      yield const AuthLoadInProgress();
      var fbUser = authRepository!.getUser();
      if (fbUser != null) {
        yield AuthLoadSuccess(fbUser);
      } else {
        yield AuthLoadInitial();
      }
    } on Exception catch (_) {
      yield AuthLoadInitial();
    }
  }

  Stream<AuthState> _mapEmailPasswordLoginToState(
      String email, String password) async* {
    try {
      yield const AuthLoadInProgress();
      var user =
          (await authRepository?.signInWithEmailAndPassword(email, password))!
              .user;
      yield AuthLoadSuccess(user);
    } on Exception catch (e) {
      yield AuthLoadFailure();
    }
  }

  Stream<AuthState> _mapForgotToState(String email) async* {
    try {
      await authRepository?.forgotPassword(email);
    } on Exception catch (_) {}
  }

  Stream<AuthState> _mapGoogleLoginToState() async* {
    try {
      yield const AuthLoadInProgress();
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        var user = (await signInWithCredential(credential));
        yield AuthLoadSuccess(user);
      } else {
        yield AuthLoadFailure();
      }
    } on Exception catch (_) {
      yield AuthLoadFailure();
    }
  }

  Stream<AuthState> _mapAppleLoginToState() async* {
    try {
      yield const AuthLoadInProgress();
      final result = await TheAppleSignIn.performRequests([
        const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);
      switch (result.status) {
        case AuthorizationStatus.authorized:
          {
            final appleIdCredential = result.credential;
            final AuthCredential credential =
                OAuthProvider('apple.com').credential(
              accessToken:
                  String.fromCharCodes(appleIdCredential!.authorizationCode!),
              idToken: String.fromCharCodes(appleIdCredential.identityToken!),
            );
            var user = (await signInWithCredential(credential));
            yield AuthLoadSuccess(user);
          }
          break;

        case AuthorizationStatus.error:
          {
            yield AuthLoadFailure();
          }
          break;

        case AuthorizationStatus.cancelled:
          yield AuthLoadFailure();
          break;
      }
    } on Exception catch (_) {
      yield AuthLoadFailure();
    }
  }

  Stream<AuthState> _mapRegisterToState(
      String email, String name, String phone) async* {
    try {
      yield const AuthLoadInProgress();
      await authRepository?.createUser(email, name, phone);
      yield const AuthLoadSuccess();
    } on Exception catch (_) {
      yield AuthLoadFailure();
    }
  }

  Stream<AuthState> _mapUpdateToState(
      String id, String email, String name, String phone) async* {
    try {
      yield const AuthLoadInProgress();
      var result = await authRepository?.updateUser(id, email, name, phone);
      if (result == true) {
        yield const AuthLoadSuccess();
      } else {
        yield AuthLoadFailure();
      }
    } on Exception catch (_) {
      yield AuthLoadFailure();
    }
  }
}
