import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCnV1x7hMbvn4stnLK9yQROqz3poad_jeA',
    appId: '1:69373787137:web:ba53b700efa071f0e39400',
    messagingSenderId: '69373787137',
    projectId: 'individual-assignment-2-a9662',
    authDomain: 'individual-assignment-2-a9662.firebaseapp.com',
    storageBucket: 'individual-assignment-2-a9662.firebasestorage.app',
    measurementId: 'G-HJ727NY7D1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCnV1x7hMbvn4stnLK9yQROqz3poad_jeA',
    appId: '1:69373787137:android:ba53b700efa071f0e39400',
    messagingSenderId: '69373787137',
    projectId: 'individual-assignment-2-a9662',
    storageBucket: 'individual-assignment-2-a9662.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCnV1x7hMbvn4stnLK9yQROqz3poad_jeA',
    appId: '1:69373787137:ios:ba53b700efa071f0e39400',
    messagingSenderId: '69373787137',
    projectId: 'individual-assignment-2-a9662',
    storageBucket: 'individual-assignment-2-a9662.firebasestorage.app',
    iosBundleId: 'com.example.bookswapApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCnV1x7hMbvn4stnLK9yQROqz3poad_jeA',
    appId: '1:69373787137:macos:ba53b700efa071f0e39400',
    messagingSenderId: '69373787137',
    projectId: 'individual-assignment-2-a9662',
    storageBucket: 'individual-assignment-2-a9662.firebasestorage.app',
    iosBundleId: 'com.example.bookswapApp',
  );
}
