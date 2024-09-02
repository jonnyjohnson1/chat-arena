import 'package:chat/analytics_drawer/conversation_steering_drawer.dart';
import 'package:chat/analytics_drawer/topic_drawer.dart';
import 'package:chat/analytics_drawer/base_anal_drawer.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/shared/custom_scroll_behavior.dart';
import 'package:chat/theming/theming_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WebAnalyticsViewDrawer extends StatefulWidget {
  final bool isMobile;
  final ValueNotifier<Widget> body;
  final ValueNotifier<String> title;
  final ValueNotifier<List<Conversation>> conversations;
  final Function? onSettingsDrawerTap;

  const WebAnalyticsViewDrawer(
      {required this.body,
      required this.title,
      required this.conversations,
      this.isMobile = false,
      this.onSettingsDrawerTap,
      super.key});

  @override
  State<WebAnalyticsViewDrawer> createState() => _WebAnalyticsViewDrawerState();
}

class _WebAnalyticsViewDrawerState extends State<WebAnalyticsViewDrawer> {
  int bottomSelectedIndex = 0;
  bool drawerIsOpen = true;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    bottomSelectedIndex = widget.isMobile ? 1 : 0;

    // Initialize pages
    pages = [
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
      }),
    ];
  }

  void onSwipeLeft() {
    if (bottomSelectedIndex < pages.length - 1) {
      setState(() {
        bottomSelectedIndex++;
      });
    }
    Future.delayed(Duration(milliseconds: transitionDur + 300), () {
      isTransition = false;
    });
  }

  void onSwipeRight() {
    if (bottomSelectedIndex > 0) {
      setState(() {
        bottomSelectedIndex--;
      });
      Future.delayed(Duration(milliseconds: transitionDur + 300), () {
        isTransition = false;
      });
    }
  }

  bool isTransition = false;
  int transitionDur = 160;

  void _onPointerSignal(PointerSignalEvent event) {
    const double scrollThreshold =
        20.0; // Adjust this value based on the sensitivity you want
    if (!isTransition) {
      if (event is PointerScrollEvent) {
        if (event.scrollDelta.dx.abs() > scrollThreshold) {
          isTransition = true;
          if (event.scrollDelta.dx > 0) {
            onSwipeLeft();
          } else if (event.scrollDelta.dx < 0) {
            onSwipeRight();
          }
        }
      }
    }
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
            Expanded(
              child: ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: Listener(
                  onPointerSignal: _onPointerSignal,
                  child: GestureDetector(
                    trackpadScrollCausesScale: true,
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! < 0) {
                        onSwipeLeft(); // Swipe left to go to the next page
                      } else if (details.primaryVelocity! > 0) {
                        onSwipeRight(); // Swipe right to go to the previous page
                      }
                    },
                    child: pages[bottomSelectedIndex],
                  ),
                ),
              ),
            ),
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

  void bottomTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      bottomSelectedIndex = index;
    });
    Future.delayed(Duration(milliseconds: transitionDur + 300), () {
      isTransition = false;
    });
  }

  List<Widget> bottomNavigationBarItems() {
    final unselectedColor = Colors.grey[350];
    return [
      AnimatedScale(
          duration: Duration(milliseconds: transitionDur),
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
          duration: Duration(milliseconds: transitionDur),
          scale: 1 == bottomSelectedIndex ? 1.15 : 1,
          child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              onTap: () => bottomTapped(1),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  CupertinoIcons.chat_bubble_2_fill,
                  color: 1 == bottomSelectedIndex
                      ? aiChatBubbleColor
                      : unselectedColor,
                  size: 21,
                ),
              ))),
      const SizedBox(
        width: 7,
      ),
      AnimatedScale(
          duration: Duration(milliseconds: transitionDur),
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
}
