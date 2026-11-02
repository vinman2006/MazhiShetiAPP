// File: lib/firebase_options.dart
// Generated for Mazhi Sheti Flutter App
// Configured with Firebase Project: mazhisheti-428da

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Android Configuration (Live)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANJtbSiBkMf-_gbLfOEJdNDqgfjgfGZno',
    appId: '1:227767908419:android:ce84fea551adc74cd9bcf6',
    messagingSenderId: '227767908419',
    projectId: 'mazhisheti-428da',
    storageBucket: 'mazhisheti-428da.firebasestorage.app',
  );

  /// Web Configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyANJtbSiBkMf-_gbLfOEJdNDqgfjgfGZno',
    appId: '1:227767908419:web:ce84fea551adc74cd9bcf6',
    messagingSenderId: '227767908419',
    projectId: 'mazhisheti-428da',
    authDomain: 'mazhisheti-428da.firebaseapp.com',
    storageBucket: 'mazhisheti-428da.firebasestorage.app',
  );

  /// iOS Configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyANJtbSiBkMf-_gbLfOEJdNDqgfjgfGZno',
    appId: '1:227767908419:ios:ce84fea551adc74cd9bcf6',
    messagingSenderId: '227767908419',
    projectId: 'mazhisheti-428da',
    storageBucket: 'mazhisheti-428da.firebasestorage.app',
    iosBundleId: 'com.mazhisheti.app',
  );

  /// macOS Configuration
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyANJtbSiBkMf-_gbLfOEJdNDqgfjgfGZno',
    appId: '1:227767908419:ios:ce84fea551adc74cd9bcf6',
    messagingSenderId: '227767908419',
    projectId: 'mazhisheti-428da',
    storageBucket: 'mazhisheti-428da.firebasestorage.app',
    iosBundleId: 'com.mazhisheti.app',
  );

  /// Windows Configuration
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyANJtbSiBkMf-_gbLfOEJdNDqgfjgfGZno',
    appId: '1:227767908419:web:ce84fea551adc74cd9bcf6',
    messagingSenderId: '227767908419',
    projectId: 'mazhisheti-428da',
    storageBucket: 'mazhisheti-428da.firebasestorage.app',
  );
}
