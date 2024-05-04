import 'package:flutter/material.dart';

Color getColor(String colorID) {
  switch (colorID) {
    case "blue":
      Color colorChoice = Colors.blue;
      return colorChoice;
    case "orange":
      Color colorChoice = Colors.orange;
      return colorChoice;
    case "green":
      Color colorChoice = Colors.green;
      return colorChoice;
    case "purple":
      Color colorChoice = Colors.purple;
      return colorChoice;
    case "light purple":
      Color colorChoice = Colors.purpleAccent;
      return colorChoice;
    case "red":
      Color colorChoice = Colors.red;
      return colorChoice;
    case "teal":
      Color colorChoice = Colors.teal;
      return colorChoice;
    case "light blue":
      Color colorChoice = Colors.lightBlue;
      return colorChoice;
    case "lime":
      Color colorChoice = Colors.lime;
      return colorChoice;
    case "pink":
      Color colorChoice = Colors.pink;
      return colorChoice;
    case "grey":
      Color colorChoice = Colors.grey;
      return colorChoice;
    case "black":
      Color colorChoice = Colors.black;
      return colorChoice;
    default:
      return Colors.black;
  }
}
