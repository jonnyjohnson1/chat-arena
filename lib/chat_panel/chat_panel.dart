import 'dart:io';

import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chat/chat_panel/conversation_list_item.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/tools.dart';

class ConversationsList extends StatefulWidget {
  final ValueNotifier<List<Conversation>> conversations;
  final onTap;
  final onDelete;
  const ConversationsList(
      {required this.conversations, this.onDelete, this.onTap, super.key});

  @override
  State<ConversationsList> createState() => _ConversationsListState();
}

class _ConversationsListState extends State<ConversationsList> {
  bool didInit = false;
  ScrollController controller = ScrollController();
  final chatALertDialogLink = LayerLink();

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 90),
        () => mounted ? setState((() => didInit = true)) : null);
    super.initState();
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
        : Column(
            children: [
              InkWell(
                onTap: () {
                  addConversation('chat');
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 18, right: 3, top: 10, bottom: 10),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text("New Game",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(
                      width: 5,
                    ),
                    Image.asset(
                      'assets/images/new_msg.png',
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Builder(builder: (more_ctx) {
                      return CompositedTransformTarget(
                        link: chatALertDialogLink,
                        child: GestureDetector(
                          onTap: () async {
                            debugPrint("\t[ Create Selection Dropdown ]");
                            String? gameType = await showGameOptions(
                                more_ctx, chatALertDialogLink);
                            debugPrint("\t\t[ Selected :: $gameType ]");
                            if (gameType != null) {
                              if (gameType == 'chat') {
                                addConversation('chat');
                              } else if (gameType == 'debate') {
                                addConversation('debate');
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Icon(
                              Icons.more_vert,
                              size: 24,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      );
                    }),
                  ]),
                ),
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
                          // physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (conversationlist[index].gameType ==
                                GameType.p2pchat) return Container();
                            return (Platform.isMacOS ||
                                    kIsWeb ||
                                    Platform.isWindows)
                                ? ConversationListItem(
                                    key: Key(conversationlist[index].id),
                                    conversation: conversationlist[index],
                                    onSelected: () {
                                      widget.onTap(conversationlist[index]);
                                    },
                                    onDeleteTap: () async {
                                      // delete from the conversations table
                                      await ConversationDatabase.instance
                                          .delete(conversationlist[index].id);
                                      print(
                                          "[ deleted conversation from table : convId: ${widget.conversations.value[index].id}]");
                                      // delete from the messages table
                                      await ConversationDatabase.instance
                                          .deleteMessageByConvId(widget
                                              .conversations.value[index].id);
                                      print(
                                          "[ deleted msgs from table with convId: convId: ${widget.conversations.value[index].id}]");
                                      print(index);
                                      try {
                                        widget.conversations.value
                                            .removeAt(index);
                                      } catch (e) {
                                        print(e);
                                      }
                                      widget.conversations.notifyListeners();
                                      widget.onDelete(true);
                                    },
                                    onSettingsTap: () async {
                                      // show alert dialog to clarify delete/clear
                                      bool? deleteConfirmation =
                                          await showAlertDialog(context);
                                      if (deleteConfirmation == true) {
                                        print("ID: " +
                                            widget
                                                .conversations.value[index].id);
                                        // delete from the conversations table
                                        await ConversationDatabase.instance
                                            .delete(widget
                                                .conversations.value[index].id);
                                        // delete from the messages table
                                        await ConversationDatabase.instance
                                            .deleteMessageByConvId(widget
                                                .conversations.value[index].id);
                                        widget.conversations.value
                                            .removeAt(index);
                                        widget.conversations.notifyListeners();
                                        widget.onDelete(true);
                                      }
                                    },
                                    isMessageRead: true,
                                  )
                                :
                                // use dismissable for mobile devices to swipe to delete
                                Dismissible(
                                    key: Key(conversationlist[index].id),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) async {
                                      // delete from the conversations table
                                      await ConversationDatabase.instance
                                          .delete(conversationlist[index].id);
                                      print(
                                          "[ deleted conversation from table : convId: ${conversationlist[index].id}]");

                                      // delete from the messages table
                                      await ConversationDatabase.instance
                                          .deleteMessageByConvId(
                                              conversationlist[index].id);
                                      print(
                                          "[ deleted msgs from table with convId: ${conversationlist[index].id}]");

                                      setState(() {
                                        conversationlist.removeAt(index);
                                      });
                                      widget.onDelete(true);
                                    },
                                    background: Container(
                                      color: const Color.fromARGB(
                                          255, 233, 56, 43),
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: ConversationListItem(
                                      key: Key(conversationlist[index].id),
                                      conversation: conversationlist[index],
                                      onSelected: () {
                                        widget.onTap(conversationlist[index]);
                                      },
                                      onDeleteTap: () async {
                                        // delete from the conversations table
                                        await ConversationDatabase.instance
                                            .delete(conversationlist[index].id);
                                        print(
                                            "[ deleted conversation from table : convId: ${widget.conversations.value[index].id}]");
                                        // delete from the messages table
                                        await ConversationDatabase.instance
                                            .deleteMessageByConvId(widget
                                                .conversations.value[index].id);
                                        print(
                                            "[ deleted msgs from table with convId: convId: ${widget.conversations.value[index].id}]");
                                        print(index);
                                        try {
                                          widget.conversations.value
                                              .removeAt(index);
                                        } catch (e) {
                                          print(e);
                                        }
                                        widget.conversations.notifyListeners();
                                        widget.onDelete(true);
                                      },
                                      onSettingsTap: () async {
                                        // show alert dialog to clarify delete/clear
                                        bool? deleteConfirmation =
                                            await showAlertDialog(context);
                                        if (deleteConfirmation == true) {
                                          print("ID: " +
                                              widget.conversations.value[index]
                                                  .id);
                                          // delete from the conversations table
                                          await ConversationDatabase.instance
                                              .delete(widget.conversations
                                                  .value[index].id);
                                          // delete from the messages table
                                          await ConversationDatabase.instance
                                              .deleteMessageByConvId(widget
                                                  .conversations
                                                  .value[index]
                                                  .id);
                                          widget.conversations.value
                                              .removeAt(index);
                                          widget.conversations
                                              .notifyListeners();
                                          widget.onDelete(true);
                                        }
                                      },
                                      isMessageRead: true,
                                    ),
                                  );
                          },
                        ),
                      );
                    }),
              ),
            ],
          );
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
              child: Material(
                color: Colors.transparent,
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
