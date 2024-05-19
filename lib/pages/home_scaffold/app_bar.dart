import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

buildAppBar(bool isMobile, ValueNotifier<String> title, int bottomSelectedIndex,
    {required Function onMenuTap,
    required Function onAnalyticsTap,
    required Function onChatsTap}) {
  return AppBar(
    automaticallyImplyLeading: false,
    leading: isMobile
        ? null
        : IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              onMenuTap();
            },
          ),
    title: ValueListenableBuilder(
      valueListenable: title,
      builder: (ctx, tit, _) {
        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            Center(
              child: Builder(builder: (ctx) {
                return InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  onTap: null,
                  // bottomSelectedIndex == 1
                  //     ? () {
                  //         print("tapped");
                  //         // _overlayPopupController(ctx);
                  //       }
                  //     : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          // overlayIsOpen
                          //     ? Colors.grey[200]
                          //     :
                          Colors.transparent,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tit,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // if (bottomSelectedIndex == 1)
                          //   Row(
                          //     children: [
                          //       const SizedBox(width: 3),
                          //       Icon(
                          //         Icons.keyboard_arrow_down_sharp,
                          //         coloColor.fromARGB(255, 41, 32, 32)600,
                          //       )
                          //     ],
                          //   ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (!isMobile)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      tooltip: "Chat Analytics",
                      onPressed: () {
                        onAnalyticsTap();
                      },
                      icon: const Icon(Icons.show_chart))
                ],
              ),
            if (isMobile)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      tooltip: "Games",
                      onPressed: () {
                        onMenuTap();
                      },
                      icon: const Icon(Icons.menu)),
                  IconButton(
                      tooltip: "Chats",
                      onPressed: () {
                        onChatsTap();
                      },
                      icon: const Icon(CupertinoIcons.chat_bubble_2))
                ],
              )
          ],
        );
      },
    ),
  );
}


// This code puts a drop down menu on the app bar title click
  // bool overlayIsOpen = false;

  // void _overlayPopupController(BuildContext ctx) {
  //   if (overlayIsOpen) {
  //     removeHoverInfoTag();
  //     setState(() {
  //       overlayIsOpen = false;
  //     });
  //   } else {
  //     setState(() {
  //       overlayIsOpen = true;
  //       showHoverInfoTag(
  //         ctx,
  //       );
  //     });
  //   }
  // }

  // OverlayEntry? suggestionStartTimeTagoverlayEntry;
  // late double height, width, xPosition, yPosition;

  // showHoverInfoTag(
  //   BuildContext context,
  // ) async {
  //   OverlayState overlayState = Overlay.of(context);
  //   RenderBox renderBox = context.findRenderObject() as RenderBox;

  //   //get location in box
  //   Offset offset = renderBox.localToGlobal(Offset.zero);
  //   width = renderBox.size.width;
  //   xPosition = offset.dx;
  //   yPosition = offset.dy;

  //   double childWidgetWidth = 310;

  //   suggestionStartTimeTagoverlayEntry = OverlayEntry(builder: (context) {
  //     return Positioned(
  //         // Decides where to place the tag on the screen.
  //         top: yPosition + 57,
  //         left: xPosition - (.5 * childWidgetWidth) + (.5 * width),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Material(
  //               color: Colors.transparent,
  //               child: Container(
  //                   constraints: const BoxConstraints(maxHeight: 490),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: const BorderRadius.all(Radius.circular(4)),
  //                     border: Border.all(width: 1, color: Colors.grey[300]!),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.grey.withOpacity(0.2),
  //                         spreadRadius: 2,
  //                         blurRadius: 3,
  //                         offset:
  //                             const Offset(0, 2), // changes position of shadow
  //                       ),
  //                     ],
  //                   ),
  //                   width: childWidgetWidth,
  //                   child: ModelSelectionList(
  //                       duration: 90,
  //                       games: games,
  //                       modelLoaded: modelLoaded,
  //                       llm: llm,
  //                       onModelTap: (ModelConfig modelConfig) {
  //                         title.value = modelConfig.displayName;
  //                         title.notifyListeners();
  //                       })),
  //             ),
  //           ],
  //         ));
  //   });
  //   overlayState.insert(suggestionStartTimeTagoverlayEntry!);
  // }

  // removeHoverInfoTag(
  //     // BuildContext context,
  //     ) async {
  //   suggestionStartTimeTagoverlayEntry!.remove();
  // }