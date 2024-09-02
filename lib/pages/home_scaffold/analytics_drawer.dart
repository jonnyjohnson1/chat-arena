import 'package:chat/analytics_drawer/conversation_steering_drawer.dart';
import 'package:chat/analytics_drawer/topic_drawer.dart';
import 'package:chat/analytics_drawer/base_anal_drawer.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/pages/home_scaffold/web_analytics_drawer.dart';
import 'package:chat/theming/theming_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnalyticsViewDrawer extends StatefulWidget {
  final bool isMobile;
  final ValueNotifier<Widget> body;
  final ValueNotifier<String> title;
  final ValueNotifier<List<Conversation>> conversations;
  final Function? onSettingsDrawerTap;

  const AnalyticsViewDrawer._internal({
    required this.body,
    required this.title,
    required this.conversations,
    this.isMobile = false,
    this.onSettingsDrawerTap,
    Key? key,
  }) : super(key: key);

  static Widget create({
    required ValueNotifier<Widget> body,
    required ValueNotifier<String> title,
    required ValueNotifier<List<Conversation>> conversations,
    bool isMobile = false,
    Function? onSettingsDrawerTap,
    Key? key,
  }) {
    if (kIsWeb) {
      return WebAnalyticsViewDrawer(
        body: body,
        title: title,
        conversations: conversations,
        isMobile: isMobile,
        onSettingsDrawerTap: onSettingsDrawerTap,
        key: key,
      );
    } else {
      return AnalyticsViewDrawer._internal(
        body: body,
        title: title,
        conversations: conversations,
        isMobile: isMobile,
        onSettingsDrawerTap: onSettingsDrawerTap,
        key: key,
      );
    }
  }

  @override
  State<AnalyticsViewDrawer> createState() => _AnalyticsViewDrawerState();
}

class _AnalyticsViewDrawerState extends State<AnalyticsViewDrawer> {
  int bottomSelectedIndex = 0;
  bool drawerIsOpen = true;

  late PageController pageController;

  @override
  void initState() {
    super.initState();
    bottomSelectedIndex = widget.isMobile ? 1 : 0;
    pageController = PageController(
      initialPage: bottomSelectedIndex,
      keepPage: true,
    );
  }

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  Widget buildPageView() {
    return PageView(
      physics: const ScrollPhysics(),
      controller: pageController,
      onPageChanged: (index) {
        pageChanged(index);
        // FirebaseAnalytics.instance.logEvent(name: getScreenName(index));
      },
      children: <Widget>[
        BaseAnalyticsDrawer(onTap: (String page) {
          if (widget.onSettingsDrawerTap != null) {
            widget.onSettingsDrawerTap!(page);
          }
        }),
        ConvSteeringDrawer(onTap: (String page) {
          if (widget.onSettingsDrawerTap != null) {
            widget.onSettingsDrawerTap!(page);
          }
        }),
        GraphAnalyticsDrawer(onTap: (String page) {
          if (widget.onSettingsDrawerTap != null) {
            widget.onSettingsDrawerTap!(page);
          }
        })
      ],
    );
  }

  void bottomTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      bottomSelectedIndex = index;
      pageController.animateToPage(index,
          duration: const Duration(milliseconds: 420), curve: Curves.ease);
    });
  }

  List<Widget> bottomNavigationBarItems() {
    final unselectedColor = Colors.grey[350];
    return [
      AnimatedScale(
          duration: const Duration(milliseconds: 160),
          scale: 0 == bottomSelectedIndex ? 1.15 : 1,
          child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              onTap: () => bottomTapped(0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  CupertinoIcons.graph_circle_fill,
                  color: 0 == bottomSelectedIndex
                      ? Colors.grey[800]
                      : unselectedColor,
                  size: 21,
                ),
              ))),
      const SizedBox(
        width: 7,
      ),
      AnimatedScale(
          duration: const Duration(milliseconds: 160),
          scale: 1 == bottomSelectedIndex ? 1.15 : 1,
          child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              onTap: () => bottomTapped(1),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  CupertinoIcons.chat_bubble_2_fill,
                  color: 1 == bottomSelectedIndex
                      ? chatIconColor
                      : unselectedColor,
                  size: 21,
                ),
              ))),
      const SizedBox(
        width: 7,
      ),
      AnimatedScale(
          duration: const Duration(milliseconds: 160),
          scale: 2 == bottomSelectedIndex ? 1.15 : 1,
          child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              onTap: () => bottomTapped(2),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.bubble_chart,
                    color: 2 == bottomSelectedIndex
                        ? const Color.fromARGB(255, 249, 144, 195)
                        : unselectedColor,
                    size: 19),
              ))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: Column(
          children: [
            Expanded(child: buildPageView()),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: bottomNavigationBarItems(),
            ),
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}
