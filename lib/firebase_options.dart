import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
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
}
