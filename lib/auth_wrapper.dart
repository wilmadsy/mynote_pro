import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/login_page.dart';
import 'pages/home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // 🔥 GANTI idTokenChanges() MENJADI authStateChanges()
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        print("STATUS: ${snapshot.connectionState}");
        print("USER: ${snapshot.data}");

        // 🔥 loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔥 kalau sudah login → ke HOME
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        }

        // 🔥 kalau belum login → ke LOGIN
        return const LoginPage();
      },
    );
  }
}