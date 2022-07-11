import 'package:flutter/material.dart';

class TextWidet extends StatelessWidget {
  late String text = '';
  FontWeight fw;
  Color color;
  late double fontSize;

  TextWidet(
      {required this.text,
      required this.fw,
      required this.color,
      required this.fontSize});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: fw,
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}
