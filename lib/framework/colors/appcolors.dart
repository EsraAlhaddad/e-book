import 'package:flutter/material.dart';
enum AppColor {//enumerated type (numaralandırılmış tip)
  appbottombar,
  backgrouncolor,
  button,
  text,
  icon,
  logcontainer,
  showdiyalogcolor,}

class AppColors {
  static final Map<AppColor, Color> _colors = {
    AppColor.appbottombar: const Color.fromARGB(209, 83, 19, 19),
    AppColor.backgrouncolor: const Color.fromARGB(255, 209, 180, 161),
    AppColor.button: const Color.fromARGB(255, 209, 180, 161),
    AppColor.text: const Color.fromARGB(255, 198, 177, 197),
    AppColor.icon: const Color.fromARGB(255, 198, 177, 197),
    AppColor.logcontainer: const Color.fromARGB(209, 71, 20, 20),
    AppColor.showdiyalogcolor:  const Color.fromARGB(209, 76, 26, 26),
    };

  static Color appbuttombar() => _colors[AppColor.appbottombar]!; // (!) kesinlikle null olmadığını belirtir.
  static Color backgrouncolor() => _colors[AppColor.backgrouncolor]!;
  static Color button() => _colors[AppColor.button]!;
  static Color text() => _colors[AppColor.text]!;
  static Color icon() => _colors[AppColor.icon]!;
  static Color logcontainer() => _colors[AppColor.logcontainer]!;
  static Color showdiyalogcolor() => _colors[AppColor.showdiyalogcolor]!;
}