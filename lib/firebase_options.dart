// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCcBjV9WJdu0_FatQ9EEFTBSVLX45fcXxA',
    appId: '1:962601600541:web:ec5f4fd9fbf9416b0328f4',
    messagingSenderId: '962601600541',
    projectId: 'lp-capital',
    authDomain: 'lp-capital.firebaseapp.com',
    storageBucket: 'lp-capital.appspot.com',
    measurementId: 'G-C02B91VCF0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDdBPNwka7YzN1NogK5JABc0JOVm1SP5kc',
    appId: '1:962601600541:android:c45b2a949fdde9840328f4',
    messagingSenderId: '962601600541',
    projectId: 'lp-capital',
    storageBucket: 'lp-capital.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC5sB8_TKLEhzf9rXra_MG8O8R52YfFlgs',
    appId: '1:962601600541:ios:f308319f5858226e0328f4',
    messagingSenderId: '962601600541',
    projectId: 'lp-capital',
    storageBucket: 'lp-capital.appspot.com',
    androidClientId: '962601600541-bae83ivf167mobs89adi95qq37uu2bki.apps.googleusercontent.com',
    iosClientId: '962601600541-ncoh8ghnjqvbgu2k1ah75dhn0qim3qvq.apps.googleusercontent.com',
    iosBundleId: 'org.lpcapital.appIp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC5sB8_TKLEhzf9rXra_MG8O8R52YfFlgs',
    appId: '1:962601600541:ios:f308319f5858226e0328f4',
    messagingSenderId: '962601600541',
    projectId: 'lp-capital',
    storageBucket: 'lp-capital.appspot.com',
    androidClientId: '962601600541-bae83ivf167mobs89adi95qq37uu2bki.apps.googleusercontent.com',
    iosClientId: '962601600541-ncoh8ghnjqvbgu2k1ah75dhn0qim3qvq.apps.googleusercontent.com',
    iosBundleId: 'org.lpcapital.appIp',
  );
}
