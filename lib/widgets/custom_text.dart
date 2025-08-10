import 'package:find_stuff/constants.dart' show Constants;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool isBold;

  CustomText({Key? key, required this.text, this.style, this.isBold = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(this.text, style: this.style ?? GoogleFonts.poppins(
        fontSize: Constants.defaultTextSize,
        fontWeight: this.isBold == true ? FontWeight.bold : FontWeight.
        normal, color: Constants.defaultTextColor, decoration: TextDecoration.none,
        decorationColor: Colors.transparent, decorationThickness: 0.0,
        decorationStyle: TextDecorationStyle.solid,
        textBaseline: TextBaseline.alphabetic, height: 1.5, letterSpacing: 0.5,
        wordSpacing: 0.5, shadows: const []));
  }
}
