import 'package:flutter/material.dart';

class IntroPage1 extends StatefulWidget {
  const IntroPage1({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IntroPage1State createState() => _IntroPage1State();
}

class _IntroPage1State extends State<IntroPage1> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Animasyonun süresi
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/intro1.jpg'), // Arka plan resmi
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          Positioned(
            top: MediaQuery.of(context).size.height / 1.5,
            left: MediaQuery.of(context).size.width / 5,
            child: ScaleTransition(
              scale: _animation,
            
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                     color: const Color.fromARGB(255, 147, 126, 119),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Welcome To E-book!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            ),
          ]
          )
        
      );
    
  }
}
