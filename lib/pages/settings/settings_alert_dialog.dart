import 'dart:io';

import 'package:chat/pages/settings/settings_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:is_ios_app_on_mac/is_ios_app_on_mac.dart';

class SettingsDialog extends StatelessWidget {
  final bool isMobile;
  const SettingsDialog({this.isMobile = false, Key? key}) : super(key: key);
  Future<bool> _isDesktopPlatform() async {
    if (kIsWeb) return false;
    return Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS ||
        await IsIosAppOnMac().isiOSAppOnMac();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _isDesktopPlatform(),
        builder: (context, isDesktop) {
          if (!isDesktop.hasData) {
            return Container();
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (isDesktop.data!) {
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
              } else {
// if (constraints.maxWidth < 700) {
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
              }
            },
          );
        });
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
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
