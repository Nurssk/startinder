import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/auth/presentation/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // ✅ Auth state listener — no more manual navigation
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Still waiting for Firebase to restore session
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF0E0F12),
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF8CF23C),
                ),
              ),
            );
          }
          // User is logged in → go to HomeScreen
          if (snapshot.hasData) {
            return const ProfileScreen();
          }
          // Not logged in → go to AuthScreen
          return const AuthScreen();
        },
      ),
    );
  }
}
