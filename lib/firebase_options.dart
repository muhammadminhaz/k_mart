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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'GOOGLE_API_KEY',
    appId: '1:729662234032:android:f776cde6929618f63a4a75',
    messagingSenderId: '729662234032',
    projectId: 'kmart-6905d',
    storageBucket: 'kmart-6905d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'GOOGLE_API_KEY',
    appId: '1:729662234032:ios:cde4377c796e4acb3a4a75',
    messagingSenderId: '729662234032',
    projectId: 'kmart-6905d',
    storageBucket: 'kmart-6905d.appspot.com',
    iosClientId: '729662234032-t7cqavgsgo49eh8paegmaucge0t4lfdd.apps.googleusercontent.com',
    iosBundleId: 'com.redminlab.kMart',
  );
}
