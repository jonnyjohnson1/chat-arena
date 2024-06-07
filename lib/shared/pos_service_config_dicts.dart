import 'package:flutter/material.dart';

class ServicePOSLabelsDict {
  double opacity = .27;
  Map<String, Color?> entitiesLabelsDict = {
    "PERSON": Colors.lightGreenAccent,
    "LOC": const Color.fromARGB(255, 113, 163, 250),
    "ORDINAL": const Color.fromARGB(255, 255, 83, 123),
    "QUANTITY": const Color.fromARGB(255, 255, 83, 123),
    "CARDINAL":
        const Color.fromARGB(255, 255, 83, 123), //TimeOfDayColors().colors[16],
    "PERCENT": const Color.fromARGB(255, 255, 83, 123),
    "DATE": const Color.fromARGB(255, 228, 102, 250),
    "TIME": const Color.fromARGB(255, 228, 102, 250),
    "ORG": const Color(0xFFfee154),
    "GPE": const Color.fromARGB(255, 28, 255, 247),
    "PRODUCT": Colors.cyan,
    "LANGUAGE": Colors.amber,
    "NORP": Colors.amberAccent,
    "FAC": const Color.fromARGB(255, 172, 172, 172),
    "LAW": const Color.fromARGB(255, 172, 172, 172),
    "WORK_OF_ART": const Color(0xFFfee154),
    "EVENT": Colors.pinkAccent,
    "MONEY": Colors.greenAccent
  };
}

class ServiceDataTypes {
//   Map<String, dynamic> serviceDataSchemas = {
//  ' ': Map<String, DialoguesResponse>
//   };
}
