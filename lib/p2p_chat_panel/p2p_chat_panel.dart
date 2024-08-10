// p2p_chat_panel.dart

import 'dart:io';

import 'package:chat/models/game_models/debate.dart';
import 'package:chat/p2p_chat_panel/conversation_list_item.dart';
import 'package:chat/p2p_chat_panel/join_chat_dialog.dart';
import 'package:chat/services/websocket_chat_client.dart';
import 'package:chat/shared/string_conversion.dart';
import 'package:chat/theming/theming_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/tools.dart';

class P2pConversationsList extends StatefulWidget {
  final ValueNotifier<List<Conversation>> conversations;
  final onTap;
  final onDelete;
  const P2pConversationsList(
      {required this.conversations, this.onDelete, this.onTap, super.key});

  @override
  State<P2pConversationsList> createState() => _P2pConversationsListState();
}

class _P2pConversationsListState extends State<P2pConversationsList> {
  bool didInit = false;
  ScrollController controller = ScrollController();
  final chatALertDialogLink = LayerLink();

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 90),
        () => mounted ? setState((() => didInit = true)) : null);
    super.initState();
  }

  hostChat() {
    Conversation newConversation = Conversation(
        id: Tools().getRandomString(10),
        title: "Untitled",
        lastMessage: "",
        image: "images/userImage1.jpeg",
        time: DateTime.now(),
        gameType: GameType.p2pchat,
        primaryModel: 'Chat');
    widget.conversations.value.insert(
      0,
      newConversation,
    );
    setState(() {
      widget.onTap(widget.conversations.value[0]);
    });
  }

  Future<void> joinChat(P2PChatGame gameSettings, context) async {
    debugPrint("[ joinChat ]");
    String httpsUrl = gameSettings.serverHostAddress!.isNotEmpty
        ? makeHTTPSAddress(gameSettings.serverHostAddress!)
        : 'http://127.0.0.1:13394';
    print("\t[ using host address $httpsUrl to check server ]");
    WebSocketChatClient testClient = WebSocketChatClient(url: httpsUrl);
    bool serverIsUp = await testClient.testEndpoint();
    if (!serverIsUp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('\t[ could not connect :: URL{$httpsUrl} ]'),
        ),
      );
    }

    if (serverIsUp) {
      String wssUrl = gameSettings.serverHostAddress!.isNotEmpty
          ? makeWebSocketAddress(gameSettings.serverHostAddress!)
          : 'ws://127.0.0.1:13394';
      var host = Uri.parse(wssUrl).host;
      debugPrint("\t[ server check good :: connecting to $host ]");

      // create the conversation with the game settings option
      Conversation newConversation = Conversation(
          id: Tools().getRandomString(10),
          title: "Untitled",
          lastMessage: "",
          image: "images/userImage1.jpeg",
          time: DateTime.now(),
          gameModel: gameSettings,
          gameType: GameType.p2pchat,
          primaryModel: 'Chat');
      widget.conversations.value.insert(
        0,
        newConversation,
      );
      setState(() {
        widget.onTap(widget.conversations.value[0]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return !didInit
        ? Container()
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 9, left: 8.0, right: 5),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        hostChat();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            255, 255, 196, 196), // Background color
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Host Chat",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Image.asset(
                            'assets/images/new_msg.png',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () async {
                        P2PChatGame? gameSettings = await joinP2PChat(context);

                        if (gameSettings != null) {
                          // switch to the game page and start as
                          gameSettings.initState = P2PServerInitState
                              .join; // sets init state so GamePage knows to join another chat
                          await joinChat(gameSettings, context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: personIconColor, // Color.fromARGB(
                        //255, 149, 207, 151), // Background color
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Join Chat",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Icon(
                            Icons.call_merge_rounded,
                            size: 20,
                            color: Colors.black87,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
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
                            // only return conversation's whose game type is p2pchat
                            if (conversationlist[index].gameType !=
                                GameType.p2pchat) return Container();
                            return (kIsWeb ||
                                    Platform.isMacOS ||
                                    Platform.isWindows)
                                ? P2pConversationListItem(
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
                                    child: P2pConversationListItem(
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
}
