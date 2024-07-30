import 'package:e_book/home/home_buttom_bar.dart';
import 'package:e_book/login/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      // ignore: non_constant_identifier_names
      builder: ((context, SnapShot) {
        if (SnapShot.hasData) {
          return const HomeBottomBar();
        } else {
          return  const SignInPage();
        }
      }),
    ));
  }
}
