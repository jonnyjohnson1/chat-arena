// home_page_layout_manager.dart

import 'dart:io';

import 'package:chat/model_widget/game_manager.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/games_config.dart';
import 'package:chat/models/model_loaded_states.dart';
import 'package:chat/models/scripts.dart';
import 'package:chat/models/sys_resources.dart';
import 'package:chat/services/env_installer.dart';
import 'package:chat/services/platform_types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:is_ios_app_on_mac/is_ios_app_on_mac.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePageLayoutManager extends StatefulWidget {
  final ValueNotifier<Widget> body;
  final ValueNotifier<String> title;
  final ValueNotifier<List<Conversation>> conversations;

  const HomePageLayoutManager({
    required this.body,
    required this.title,
    required this.conversations,
    super.key,
  });

  @override
  State<HomePageLayoutManager> createState() => _HomePageLayoutManagerState();
}

class _HomePageLayoutManagerState extends State<HomePageLayoutManager> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Size>(
      future: _fetchSize(context),
      builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        return FutureBuilder<bool>(
          future: isDesktopPlatform(includeIosAppOnMac: true),
          builder: (context, isDesktop) {
            if (!isDesktop.hasData) {
              return Container(color: Colors.white);
            }
            bool isMobile = !isDesktop.data!;

            return MultiProvider(
              providers: [Provider.value(value: true)],
              child: SelectionArea(
                child: Scaffold(
                  key: _scaffoldKey,
                  body: Container(
                    color: Colors.white,
                    child: SafeArea(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (_) {
                          // add any close menu items here if needed
                        },
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        child: Center(
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  color: Colors.white,
                                  child: ValueListenableBuilder(
                                    valueListenable: widget.body,
                                    builder: (context, home, _) {
                                      return Column(
                                        children: [
                                          Expanded(child: home),
                                          _buildClickableText(), // Add the clickable text here
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildClickableText() {
    const url = 'https://calendar.google.com/calendar/appointments/schedules/AcZssZ38Kg7Pj8ipSHo3vDWQuaAUH7gfvvlP9hBw2MiF9QvATeZM6auZu_zkC4lXlCF2MwFB7IxyZbNb';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () async {
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        },
        child: RichText(
          text: TextSpan(
            text: 'Schedule a Meeting with Nick',
            style: TextStyle(
              color: Colors.blue, // Text color for clickable text
              decoration: TextDecoration.underline, // Underline the text to indicate it's clickable
            ),
          ),
        ),
      ),
    );
  }

  Future<Size> _fetchSize(BuildContext context) async {
    // Wait for the first frame to be built
    await Future.delayed(Duration.zero);
    return MediaQuery.of(context).size;
  }
}
