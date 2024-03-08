import 'package:flutter/material.dart';

class RobotoNormalText extends StatelessWidget {

  final String text;
  final double fontSize;
  Color color;
  TextAlign align;

  RobotoNormalText({
    super.key,
    required this.text,
    required this.fontSize,
    this.color = Colors.white,
    this.align = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: TextStyle(
          color: color,
          fontWeight: FontWeight.normal,
          fontSize: fontSize,
          fontFamily: 'Roboto'
      ),
      textAlign: align,
    );
  }
}
