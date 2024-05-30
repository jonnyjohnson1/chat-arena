import 'package:chat/pages/settings/settings_page.dart';
import 'package:flutter/cupertino.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 15, 8.0, 0),
      child: SettingsPage(),
    );
  }
}
