import 'package:e_book/framework/colors/appcolors.dart';
//import 'package:e_book/home/home_page.dart'; 
import 'package:e_book/login/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  Future<void> signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.showdiyalogcolor(),
            title: Text(
              'Error',
              style: TextStyle(
                color: AppColors.text(),
              ),
            ),
            content: Text(
              'Please enter email and password.',
              style: TextStyle(
                color: AppColors.text(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: AppColors.text(),
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.showdiyalogcolor(),
            title: Text(
              'Error',
              style: TextStyle(
                color: AppColors.text(),
              ),
            ),
            content: Text(
              'Passwords do not match.',
              style: TextStyle(
                color: AppColors.text(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: AppColors.text(),
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => const Auth(), 
        ),
      );
    } catch (e) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.showdiyalogcolor(),
            title: Text(
              'Error',
              style: TextStyle(
                color: AppColors.text(),
              ),
            ),
            content: Text(
              'e-mail address is not correct',
              style: TextStyle(
                color: AppColors.text(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: AppColors.text(),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Başlangıç konumu: alttan yukarıya doğru
      end: const Offset(0.0, 0.0), // Bitiş konumu: tam ortasında
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SIGN UP',
          style: TextStyle(
            color: AppColors.text(),
          ),
        ),
        backgroundColor: AppColors.appbuttombar(),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.icon(),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          // Arka plan resmi
          Positioned.fill(
            child: Image.asset(
              "images/signin.jpg",
              fit: BoxFit.cover,
            ),
          ),

          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
                SlideTransition(
                  position: _animation,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppColors.logcontainer(),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Here You Can Sign Up !',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text(),
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          style: TextStyle(
                            color: AppColors.text(),
                          ),
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                color: AppColors.text(),
                                fontWeight: FontWeight.bold),
                            labelText: 'Email',
                            prefixIcon: Icon(
                              Icons.email,
                              color: AppColors.icon(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          style: TextStyle(
                            color: AppColors.text(),
                          ),
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                color: AppColors.text(),
                                fontWeight: FontWeight.bold),
                            labelText: 'Password',
                            prefixIcon:
                                Icon(Icons.lock, color: AppColors.icon()),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          style: TextStyle(
                            color: AppColors.text(),
                          ),
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                color: AppColors.text(),
                                fontWeight: FontWeight.bold),
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(
                              Icons.lock,
                              color: AppColors.icon(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 60),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: AppColors.button(),
                          ),
                          child: Center(
                            child: GestureDetector(
                              onTap: signUp,
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                    color: Color.fromARGB(209, 65, 17, 17),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already Have An Account?",
                              style: TextStyle(color: AppColors.text()),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Auth()),
                                );
                              },
                              child: Text('Sign In',
                                  style: TextStyle(
                                      color: AppColors.text(),
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
