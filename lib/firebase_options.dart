import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    }
    throw UnsupportedError('Platform not configured yet.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDUyzqw8YO1W-8-8oLxW9x5yxsGxgdr958",
    authDomain: "hackathon-team-builder.firebaseapp.com",
    projectId: "hackathon-team-builder",
    storageBucket: "hackathon-team-builder.firebasestorage.app",
    messagingSenderId: "1002341265643",
    appId: "1:1002341265643:web:fa280a45701324fe850eae",
    measurementId: "G-T20BMRQ0NJ",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJq0GrZLoJcC1-bznAIKLkyVHD1m5-2rM',
    appId: '1:1002341265643:android:e8387d512f4f1859850eae',
    messagingSenderId: '1002341265643',
    projectId: 'hackathon-team-builder',
    storageBucket: 'hackathon-team-builder.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCJq0GrZLoJcC1-bznAIKLkyVHD1m5-2rM',
    appId: '1:1002341265643:ios:fa280a45701324fe850eae',
    messagingSenderId: '1002341265643',
    projectId: 'hackathon-team-builder',
    storageBucket: 'hackathon-team-builder.firebasestorage.app',
    iosBundleId: 'com.example.start',
  );
}
