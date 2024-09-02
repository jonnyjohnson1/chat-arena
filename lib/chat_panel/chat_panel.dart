import 'dart:io';

import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:chat/theming/theming_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chat/chat_panel/conversation_list_item.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/tools.dart';

class AIChatList extends StatefulWidget {
  final ValueNotifier<List<Conversation>> conversations;
  final bool isMobileLayout;
  final onTap;
  final onSettingsTap;
  final onDelete;
  const AIChatList(
      {required this.conversations,
      required this.isMobileLayout,
      required this.onSettingsTap,
      this.onDelete,
      this.onTap,
      super.key});

  @override
  State<AIChatList> createState() => _AIChatListState();
}

class _AIChatListState extends State<AIChatList> {
  bool didInit = false;
  ScrollController controller = ScrollController();
  ValueNotifier<bool> hasScrolledNotifier = ValueNotifier<bool>(false);

  final chatALertDialogLink = LayerLink();

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 90),
        () => mounted ? setState((() => didInit = true)) : null);
    controller.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    if (controller.offset > 0 && !hasScrolledNotifier.value) {
      hasScrolledNotifier.value = true;
    } else if (controller.offset <= 0 && hasScrolledNotifier.value) {
      hasScrolledNotifier.value = false;
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onScroll);
    controller.dispose();
    hasScrolledNotifier.dispose();
    super.dispose();
  }

  addConversation(String gameType) {
    Conversation newConversation = Conversation(
        id: Tools().getRandomString(10),
        title: "Untitled",
        lastMessage: "",
        image: "images/userImage1.jpeg",
        time: DateTime.now(),
        gameType: gameType == 'chat' ? GameType.chat : GameType.debate,
        primaryModel: 'Chat');
    widget.conversations.value.insert(
      0,
      newConversation,
    );
    // ConversationDatabase.instance.create(newConversation);
    setState(() {
      widget.onTap(widget.conversations.value[0]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return !didInit
        ? Container()
        : Material(
            color: Colors.transparent,
            child: Column(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: hasScrolledNotifier,
                  builder: (context, hasScrolled, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        boxShadow: hasScrolled
                            ? [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    blurRadius: 4.0)
                              ]
                            : [],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 18, right: 3, top: 10, bottom: 10),
                        child: SelectionContainer.disabled(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (widget.isMobileLayout)
                                InkWell(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(13)),
                                  onTap: () {
                                    widget.onSettingsTap();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8.0),
                                    child: Center(
                                        child: Text("Configure",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary))),
                                  ),
                                ),
                              Expanded(
                                child: InkWell(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(13)),
                                  onTap: () {
                                    addConversation('chat');
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text("New Chat",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          Icons.graphic_eq,
                                          color: aiChatBubbleColor,
                                        ),
                                        const SizedBox(
                                          width: 25,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: widget.conversations,
                    builder: (context, conversationlist, _) {
                      return Scrollbar(
                        controller: controller,
                        child: ListView.builder(
                          controller: controller,
                          itemCount: conversationlist.length,
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(top: 4),
                          itemBuilder: (context, index) {
                            if (conversationlist[index].gameType ==
                                GameType.p2pchat) return Container();
                            if (kIsWeb) {
                              return _buildWebConversationItem(
                                  context, conversationlist[index], index);
                            } else if (Platform.isMacOS || Platform.isWindows) {
                              return _buildDesktopConversationItem(
                                  context, conversationlist[index], index);
                            } else {
                              return _buildMobileConversationItem(
                                  context, conversationlist[index], index);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }

  // Builder(builder: (more_ctx) {
  //   return CompositedTransformTarget(
  //     link: chatALertDialogLink,
  //     child: GestureDetector(
  //       onTap: () async {
  //         debugPrint("\t[ Create Selection Dropdown ]");
  //         String? gameType = await showGameOptions(
  //             more_ctx, chatALertDialogLink);
  //         debugPrint("\t\t[ Selected :: $gameType ]");
  //         if (gameType != null) {
  //           if (gameType == 'chat') {
  //             addConversation('chat');
  //           } else if (gameType == 'debate') {
  //             addConversation('debate');
  //           }
  //         }
  //       },
  //       child: Padding(
  //         padding: const EdgeInsets.all(3.0),
  //         child: Icon(
  //           Icons.more_vert,
  //           size: 24,
  //           color: Colors.grey.shade600,
  //         ),
  //       ),
  //     ),
  //   );
  // }),

  Widget _buildDesktopConversationItem(
      BuildContext context, Conversation conversation, int index) {
    return ConversationListItem(
      key: Key(conversation.id),
      conversation: conversation,
      onSelected: () {
        widget.onTap(conversation);
      },
      onDeleteTap: () async {
        await _deleteConversation(index);
        widget.onDelete(true);
      },
      onSettingsTap: () async {
        bool? deleteConfirmation = await showAlertDialog(context);
        if (deleteConfirmation == true) {
          await _deleteConversation(index);
          widget.onDelete(true);
        }
      },
      isMessageRead: true,
    );
  }

  Widget _buildWebConversationItem(
      BuildContext context, Conversation conversation, int index) {
    return ConversationListItem(
      key: Key(conversation.id),
      conversation: conversation,
      onSelected: () {
        widget.onTap(conversation);
      },
      onDeleteTap: () async {
        await _deleteConversation(index);
        widget.onDelete(true);
      },
      onSettingsTap: () async {
        bool? deleteConfirmation = await showAlertDialog(context);
        if (deleteConfirmation == true) {
          await _deleteConversation(index);
          widget.onDelete(true);
        }
      },
      isMessageRead: true,
    );
  }

  Widget _buildMobileConversationItem(
      BuildContext context, Conversation conversation, int index) {
    return Column(
      children: [
        Dismissible(
          key: Key(conversation.id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) async {
            await _deleteConversation(index);
            setState(() {
              widget.conversations.value.removeAt(index);
            });
            widget.onDelete(true);
          },
          background: Container(
            color: const Color.fromARGB(255, 233, 56, 43),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: ConversationListItem(
              key: Key(conversation.id),
              conversation: conversation,
              onSelected: () {
                widget.onTap(conversation);
              },
              onDeleteTap: () async {
                await _deleteConversation(index);
                widget.onDelete(true);
              },
              onSettingsTap: () async {
                bool? deleteConfirmation = await showAlertDialog(context);
                if (deleteConfirmation == true) {
                  await _deleteConversation(index);
                  widget.onDelete(true);
                }
              },
              isMessageRead: true,
            ),
          ),
        ),
        if (widget.conversations.value.length - 1 != index)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(
              height: 1,
              color: Colors.black12,
            ),
          )
      ],
    );
  }

  Future<void> _deleteConversation(int index) async {
    await ConversationDatabase.instance
        .delete(widget.conversations.value[index].id);
    print(
        "[ deleted conversation from table : convId: ${widget.conversations.value[index].id}]");
    await ConversationDatabase.instance
        .deleteMessageByConvId(widget.conversations.value[index].id);
    print(
        "[ deleted msgs from table with convId: ${widget.conversations.value[index].id}]");
    try {
      widget.conversations.value.removeAt(index);
    } catch (e) {
      print(e);
    }
    widget.conversations.notifyListeners();
  }

  Future<String?> showGameOptions(
      BuildContext context, LayerLink layerLink) async {
    final offset = const Offset(0, -22);
    return await showAlignedDialog(
        context: context,
        avoidOverflow: true,
        isGlobal: false,
        followerAnchor: Alignment.bottomLeft,
        targetAnchor: Alignment.topLeft,
        barrierColor: Colors.transparent,
        duration: const Duration(milliseconds: 100),
        builder: (context) {
          return CompositedTransformFollower(
              offset: offset,
              link: layerLink,
              child: SizedBox(
                width: 240,
                height: 190,
                child: AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Row(
                        children: [
                          SizedBox(
                            width: 17,
                          ),
                          Text(
                            "Pick a game:",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Icon(CupertinoIcons.chat_bubble_fill,
                                  color: Colors.blue[200], size: 16),
                            ),
                            const Text('Chat'),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context, 'chat');
                        },
                      ),
                      ListTile(
                        title: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: Icon(CupertinoIcons.group_solid,
                                  color: Color.fromARGB(255, 188, 144, 249),
                                  size: 20),
                            ),
                            Text('Debate')
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context, 'debate');
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      )
                    ],
                  ),
                ),
              ));
        });
  }
}

Future<bool?> showAlertDialog(BuildContext context) {
  // set up the button
  Widget clearButton = TextButton(
    child: const Text("Delete",
        style: TextStyle(color: Color.fromARGB(255, 211, 47, 47))),
    onPressed: () {
      Navigator.of(context).pop(true);
      // Navigator.pop(context, "clear");
    },
  );

  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0))),
    elevation: 4,
    content: SelectionArea(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        child: const Text(
          'Delete the conversation?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    // content: Text("This is my message."),
    actions: [clearButton, cancelButton],
  );

  // show the dialog
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
