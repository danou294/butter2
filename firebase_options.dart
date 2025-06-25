import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.android:
        return android;
      case TargetPlatform.macOS:
        return ios; // même config que iOS
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChWVS_PDX6PizXH24IITn0qvx88DsBZic',
    appId: '1:743945650254:android:51480737f9e46d5c41831f',
    messagingSenderId: '743945650254',
    projectId: 'butter-vdef',
    storageBucket: 'butter-vdef.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChWVS_PDX6PizXH24IITn0qvx88DsBZic',
    appId: '1:743945650254:ios:48dbfd3a99ba595641831f',
    messagingSenderId: '743945650254',
    projectId: 'butter-vdef',
    storageBucket: 'butter-vdef.appspot.com',
    iosBundleId: 'com.example.butter-new',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyChWVS_PDX6PizXH24IITn0qvx88DsBZic',
    appId: '1:743945650254:web:b95b5c5374f322f941831f',
    messagingSenderId: '743945650254',
    projectId: 'butter-vdef',
    authDomain: 'butter-vdef.firebaseapp.com',
    storageBucket: 'butter-vdef.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );
}