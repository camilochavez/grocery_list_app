import 'dart:ui';
import 'package:flutter/material.dart';

class AppStyle {
  static TextStyle get titleStyle => TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.teal[900],
          fontSize: 18.0,
          decorationThickness: 3.0,
          decoration: TextDecoration.underline,
          shadows: [
            BoxShadow(
                color: Colors.white24,
                blurRadius: 5.0,
                offset: Offset(3.0, 3.0))
          ]);
  static TextStyle get subTitleStyle => TextStyle(
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white24,
          color: Colors.teal[900],
          fontSize: 15.0,
          decorationThickness: 3.0,
          decoration: TextDecoration.underline,
          shadows: [
            BoxShadow(
                color: Colors.white, blurRadius: 5.0, offset: Offset(3.0, 3.0))
          ]);
  static   Color getColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.redAccent[700];
        break;
      case 2:
        return Colors.orange[700];
        break;
      case 3:
        return Colors.lightBlueAccent;
        break;
      default:
        return Colors.green;
    }
  }
}
