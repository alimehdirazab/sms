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
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB3YOJ7uIrt1QrP346-MgJ18JdpcePn6C8',
    appId: '1:829909578885:android:e718edfb2c52152d44a5ec',
    messagingSenderId: '829909578885',
    projectId: 'school-erp-noti',
    storageBucket: 'school-erp-noti.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB3YOJ7uIrt1QrP346-MgJ18JdpcePn6C8',
    appId: '1:829909578885:android:e718edfb2c52152d44a5ec',
    messagingSenderId: '829909578885',
    projectId: 'school-erp-noti',
    storageBucket: 'school-erp-noti.firebasestorage.app',
  );
}

