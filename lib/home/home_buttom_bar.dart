import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:e_book/framework/colors/appcolors.dart';
import 'package:e_book/home_bottom_pages/favorite_page.dart';
import 'package:e_book/home_bottom_pages/message.dart';
import 'package:e_book/home_bottom_pages/profile_page.dart';
import 'package:e_book/home/home_page.dart';
import 'package:flutter/material.dart';


class HomeBottomBar extends StatefulWidget {
  const HomeBottomBar({super.key});
  @override
  State<HomeBottomBar> createState() => _HomeBottomBarState();
}

class _HomeBottomBarState extends State<HomeBottomBar> {
  var _index = 0;

  List<Widget> pages = <Widget>[
    const HomePage(),
    const Favorite(),
    const Message(),
    const Profile()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages.elementAt(_index),
      bottomNavigationBar: CurvedNavigationBar(
        color: AppColors.appbuttombar(),
        backgroundColor:  const Color.fromARGB(255, 209, 180, 161),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 250),
        index: _index,
        onTap: (index) {
          setState(() {
            _index = index;
          });
        },
        items:  [
          Icon(Icons.home, size: 30, color:   AppColors.icon()),
          Icon(Icons.favorite_outlined, size: 30, color: AppColors.icon()),
          Icon(Icons.message_outlined, size: 30, color: AppColors.icon()),
          Icon(Icons.person, size: 30, color: AppColors.icon()),
        ],
      ),
    );
  }
}
