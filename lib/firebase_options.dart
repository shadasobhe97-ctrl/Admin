import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with Firebase.initializeApp.
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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDiTBvIn7NofN026K_JLAdyL_XgEb6iylY',
    appId: '1:745946017392:web:fe4914a2eb42bcf9cf8eb5',
    messagingSenderId: '745946017392',
    projectId: 'darpy-a247d',
    authDomain: 'darpy-a247d.firebaseapp.com',
    storageBucket: 'darpy-a247d.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDiTBvIn7NofN026K_JLAdyL_XgEb6iylY',
    appId: '1:745946017392:android:55e3eef6bb60f089cf8eb5',
    messagingSenderId: '745946017392',
    projectId: 'darpy-a247d',
    storageBucket: 'darpy-a247d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDiTBvIn7NofN026K_JLAdyL_XgEb6iylY',
    appId: '1:745946017392:ios:55e3eef6bb60f089cf8eb5',
    messagingSenderId: '745946017392',
    projectId: 'darpy-a247d',
    storageBucket: 'darpy-a247d.firebasestorage.app',
    iosBundleId: 'com.darpy.app',
  );
}
