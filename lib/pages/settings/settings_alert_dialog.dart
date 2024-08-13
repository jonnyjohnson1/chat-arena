import 'package:chat/pages/settings/settings_page.dart';
import 'package:flutter/material.dart';

class SettingsDialog extends StatelessWidget {
  final bool isMobile;
  const SettingsDialog({this.isMobile = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          // Mobile layout
          return AlertDialog(
            content: SizedBox(
              width: constraints.maxWidth * 0.9,
              height: constraints.maxHeight * 0.8,
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: SettingsPage()),
                ],
              ),
            ),
          );
        } else {
          // Desktop/iPad layout
          return AlertDialog(
            content: SizedBox(
              width: constraints.maxWidth * 0.8,
              height: constraints.maxHeight * 0.6,
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: SettingsPage()),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Settings', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
