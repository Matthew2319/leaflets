import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // You will need to replace these placeholder values with your actual Firebase configuration
    // You can get these values from your Firebase Console after adding your app
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCFj7nVHsEV8WbRgBV3535VtBrbdqJ86lg',
    appId: '1:169059230273:web:fe6d8150e4ea718d80985a',
    messagingSenderId: '169059230273',
    projectId: 'leaflets-1a3ce',
    authDomain: 'leaflets-1a3ce.firebaseapp.com',
    storageBucket: 'leaflets-1a3ce.firebasestorage.app',
    measurementId: 'G-measurement-id',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFj7nVHsEV8WbRgBV3535VtBrbdqJ86lg',
    appId: '1:169059230273:android:53417895a4ba9f86285cc0',
    messagingSenderId: '169059230273',
    projectId: 'leaflets-1a3ce',
    storageBucket: 'leaflets-1a3ce.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCFj7nVHsEV8WbRgBV3535VtBrbdqJ86lg',
    appId: '1:169059230273:ios:d8e9e76514e4d91e80985a',
    messagingSenderId: '169059230273',
    projectId: 'leaflets-1a3ce',
    storageBucket: 'leaflets-1a3ce.firebasestorage.app',
    iosClientId: '169059230273-h8v8v8h8v8h8v8h8v8h8v8h8v8h8.apps.googleusercontent.com',
    iosBundleId: 'com.example.leaflets',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCFj7nVHsEV8WbRgBV3535VtBrbdqJ86lg',
    appId: '1:169059230273:ios:d8e9e76514e4d91e80985a',
    messagingSenderId: '169059230273',
    projectId: 'leaflets-1a3ce',
    storageBucket: 'leaflets-1a3ce.firebasestorage.app',
    iosClientId: '169059230273-h8v8v8h8v8h8v8h8v8h8v8h8v8h8.apps.googleusercontent.com',
    iosBundleId: 'com.example.leaflets',
  );
} 