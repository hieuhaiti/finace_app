import 'package:flutter/material.dart';

class TColor {
  static Color get primary => const Color(0xff5E00F5);
  static Color get primary500 => const Color(0xff7722FF);
  static Color get primary20 => const Color(0xff924EFF);
  static Color get primary10 => const Color(0xffAD7BFF);
  static Color get primary5 => const Color(0xffC9A7FF);
  static Color get primary0 => const Color(0xffE4D3FF);

  static Color get secondary => const Color(0xffFF7966);
  static Color get secondary50 => const Color(0xffFFA699);
  static Color get secondary0 => const Color(0xffFFD2CC);

  static Color get secondaryG => const Color(0xff00FAD9);
  static Color get secondaryG50 => const Color(0xff7DFFEE);

  static Color get gray => const Color(0xff0E0E12);
  static Color get gray80 => const Color(0xff1C1C23);
  static Color get gray70 => const Color(0xff353542);
  static Color get gray60 => const Color(0xff4E4E61);
  static Color get gray50 => const Color(0xff666680);
  static Color get gray40 => const Color(0xff83839C);
  static Color get gray30 => const Color(0xffA2A2B5);
  static Color get gray20 => const Color(0xffC1C1CD);
  static Color get gray10 => const Color(0xffE0E0E6);

  static Color get border => const Color(0xffCFCFFC);
  static Color get primaryText => Colors.white;
  static Color get secondaryText => gray20;
  static Color get thirdText => gray30;
  static Color get fourthText => gray40;
  static Color get fifthText => gray50;

  static Color get white => const Color(0xFFFFFFFF);

  static Color get green => const Color(0xFF689F38);
  static Color get lightGreen => const Color(0xFF9CCC65);
  static Color get greenWithOpacity => const Color(0xFF689F38).withAlpha(200);
  static Color get red => const Color(0xFFD32F2F);
  static Color get lightRed => const Color(0xFFEF5350);
  static Color get redWithOpacity => const Color(0xFFD32F2F).withAlpha(200);

  static Color get blue => const Color(0xFF1976D2);
  static Color get lightBlue => const Color(0xFF64B5F6);
}
