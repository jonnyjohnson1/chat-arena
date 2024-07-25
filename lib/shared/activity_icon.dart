import 'package:flutter/material.dart';

class ActivityIcon extends StatelessWidget {
  final isRunning;
  const ActivityIcon({this.isRunning = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isRunning ? Colors.green : Colors.grey,
      ),
    );
  }
}
