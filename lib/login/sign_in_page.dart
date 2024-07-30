import 'package:e_book/framework/colors/appcolors.dart';
import 'package:e_book/login/sign_up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return; // googleUser null ise işlem yapmadan fonksiyondan çık
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signIn() async {
    try {
      // Eğer e-mail ve şifre alanları boş ise kullanıcıya uyarı ver
      if (email.text.isEmpty || password.text.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.showdiyalogcolor(),
              title:  Text(
                'Error',
                style: TextStyle(
                  color:AppColors.text(),
                ),
              ),
              content:  Text(
                'Please enter your email and password',
                style: TextStyle(
                  color:AppColors.text(),
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
                      color:AppColors.text(),
                    ),
                  ),
                ),
              ],
            );
          },
        );
        return;
      }

      // Firebase ile giriş yap
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
    } catch (e) {
      // Eğer hata alınırsa, e-mail adresi yanlış mesajı
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.showdiyalogcolor(),
            title:  Text(
              'Error',
              style: TextStyle(
                color: AppColors.text(),
              ),
            ),
            content:  Text(
              'Incorrect email or password. Please enter correct information.',
              style: TextStyle(
                color: AppColors.text(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child:  Text(
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

  late AnimationController _animacontroller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _animacontroller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Başlangıç konumu: alttan yukarıya doğru
      end: const Offset(0.0, 0.0), // Bitiş konumu: tam ortasında
    ).animate(CurvedAnimation(
      parent: _animacontroller,
      curve: Curves.easeInOut,
    ));
    _animacontroller.forward();
  }

  @override
  void dispose() {
    _animacontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SIGN IN',
          style: TextStyle(color: AppColors.text()),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: email,
                          style: TextStyle(color: AppColors.text()),
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.text()),
                            labelText: 'Email',
                            prefixIcon:
                                Icon(Icons.email, color: AppColors.icon()),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: password,
                          obscureText: true,
                          style: TextStyle(color: AppColors.text()),
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.text()),
                            labelText: 'Password',
                            prefixIcon:
                                Icon(Icons.lock, color: AppColors.icon()),
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () async {
                            if (email.text == "") {
                              // email boşsa
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor:
                                         AppColors.showdiyalogcolor(),
                                      title:  Text(
                                        'Error',
                                        style: TextStyle(
                                          color:AppColors.text(),
                                        ),
                                      ),
                                      content: Text(
                                        'Please Enter Your Email ',
                                        style: TextStyle(
                                          color: AppColors.text(),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child:  Text(
                                            'OK',
                                            style: TextStyle(
                                              color: AppColors.text(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  });
                              return;
                            }
                            //yanlış veya var olmayan bir email girilmişse
                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(email: email.text);
                              showDialog(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor:
                                          AppColors.showdiyalogcolor(),
                                      title:  Text(
                                        'Done',
                                        style: TextStyle(
                                          color:AppColors.text(),
                                        ),
                                      ),
                                      content:  Text(
                                        'We Sent To You An Email To Create A New Password',
                                        style: TextStyle(
                                          color:AppColors.text(),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child:  Text(
                                            'OK',
                                            style: TextStyle(
                                              color: AppColors.text(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  });
                            } catch (e) {
                              showDialog(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor:
                                         AppColors.showdiyalogcolor(),
                                      title:  Text(
                                        'Error',
                                        style: TextStyle(
                                          color:AppColors.text(),
                                        ),
                                      ),
                                      content: Text(
                                        'Your Email İs Not Correct',
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
                                              color:AppColors.text(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  });
                            }
                          },
                          child: Container(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: AppColors.text()),
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
                              onTap: () => signIn(),
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                    color: Color.fromARGB(209, 65, 17, 17),
                                    fontWeight: FontWeight.bold),
                              ),
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
                              onTap: () => signInWithGoogle(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Or Sign In with Google",
                                    style: TextStyle(
                                        color: Color.fromARGB(209, 65, 17, 17),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 10),
                                  Image.asset(
                                    "images/google.jpg",
                                    width: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't Have An Account?",
                              style: TextStyle(color: AppColors.text()),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SignUpPage()),
                                );
                              },
                              child: Text('Sign Up',
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
