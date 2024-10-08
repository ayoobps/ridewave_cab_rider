// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyA-w7ZourntVOnte00RNbMbT-6YAjB7Bac',
    appId: '1:6927091013:web:23364cd9457d1c2f50ea2c',
    messagingSenderId: '6927091013',
    projectId: 'ridewave-cab-all',
    authDomain: 'ridewave-cab-all.firebaseapp.com',
    storageBucket: 'ridewave-cab-all.appspot.com',
    measurementId: 'G-TVL5D0HWHD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBaoRkkt-Gl0UCh4TKtQ4HC0kXm3dE3Mhw',
    appId: '1:6927091013:android:fb1c3b284f1e379e50ea2c',
    messagingSenderId: '6927091013',
    projectId: 'ridewave-cab-all',
    storageBucket: 'ridewave-cab-all.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCBnOBJCaLuCpOlPyFdevifDcQpIzMttxA',
    appId: '1:6927091013:ios:5478c91953e5faf450ea2c',
    messagingSenderId: '6927091013',
    projectId: 'ridewave-cab-all',
    storageBucket: 'ridewave-cab-all.appspot.com',
    iosBundleId: 'com.yallahsoft.ridewaveCabRider',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCBnOBJCaLuCpOlPyFdevifDcQpIzMttxA',
    appId: '1:6927091013:ios:5478c91953e5faf450ea2c',
    messagingSenderId: '6927091013',
    projectId: 'ridewave-cab-all',
    storageBucket: 'ridewave-cab-all.appspot.com',
    iosBundleId: 'com.yallahsoft.ridewaveCabRider',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA-w7ZourntVOnte00RNbMbT-6YAjB7Bac',
    appId: '1:6927091013:web:09ed950b5c4fe37350ea2c',
    messagingSenderId: '6927091013',
    projectId: 'ridewave-cab-all',
    authDomain: 'ridewave-cab-all.firebaseapp.com',
    storageBucket: 'ridewave-cab-all.appspot.com',
    measurementId: 'G-FN54NMG5P4',
  );
}
