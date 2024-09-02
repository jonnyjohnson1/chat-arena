// p2p_chat_panel.dart

import 'dart:io';
import 'package:chat/models/display_configs.dart';
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
import 'package:provider/provider.dart';

class P2pConversationsList extends StatefulWidget {
  final ValueNotifier<List<Conversation>> conversations;
  final bool isMobileLayout;
  final onTap;
  final onSettingsTap;
  final onDelete;
  const P2pConversationsList(
      {required this.conversations,
      required this.isMobileLayout,
      required this.onSettingsTap,
      this.onDelete,
      this.onTap,
      super.key});

  @override
  State<P2pConversationsList> createState() => _P2pConversationsListState();
}

class _P2pConversationsListState extends State<P2pConversationsList> {
  bool didInit = false;
  ScrollController controller = ScrollController();
  final chatALertDialogLink = LayerLink();
  late ValueNotifier<DisplayConfigData> displayConfigData;

  ValueNotifier<bool> hasScrolledNotifier = ValueNotifier<bool>(false);
  @override
  void initState() {
    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);
    Future.delayed(const Duration(milliseconds: 90),
        () => mounted ? setState((() => didInit = true)) : null);

    controller.addListener(_onScroll);
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
    String httpsUrl = "";
    // user input the url from their menu
    if (gameSettings.serverHostAddress!.isNotEmpty) {
      httpsUrl = makeHTTPSAddress(gameSettings.serverHostAddress!);
    } else {
      // use a default endping
      httpsUrl = displayConfigData.value.apiConfig.getDefaultMessengerBackend();
    }

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
      String wssUrl = makeWebSocketAddress(httpsUrl);
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

  @override
  Widget build(BuildContext context) {
    return !didInit
        ? Container()
        : Column(
            children: [
              ValueListenableBuilder<bool>(
                  valueListenable: hasScrolledNotifier,
                  builder: (context, hasScrolled, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(0, 255, 255, 255),
                        boxShadow: hasScrolled
                            ? [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    blurRadius: 4.0)
                              ]
                            : [],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 18, right: 3, top: 10, bottom: 5),
                            child: SelectionContainer.disabled(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (widget.isMobileLayout)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8.0),
                                      child: Center(
                                          child: Text("Messages",
                                              style: TextStyle(
                                                letterSpacing: 1.24,
                                                fontWeight: FontWeight.w500,
                                              ))),
                                    ),
                                  // InkWell(
                                  //   borderRadius: const BorderRadius.all(
                                  //       Radius.circular(13)),
                                  //   onTap: () {
                                  //     widget.onSettingsTap();
                                  //   },
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.symmetric(
                                  //         vertical: 4, horizontal: 8.0),
                                  //     child: Center(
                                  //         child: Text("Configure",
                                  //             style: TextStyle(
                                  //                 fontWeight: FontWeight.w500,
                                  //                 color: Theme.of(context)
                                  //                     .colorScheme
                                  //                     .primary))),
                                  //   ),
                                  // ),
                                  Expanded(
                                    child: Material(
                                      color: const Color.fromARGB(
                                          0, 255, 255, 255),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: aiChatBubbleColor
                                                    .withOpacity(.11),
                                                border: Border.all(
                                                    color: aiChatBubbleColor),
                                                shape: BoxShape.circle),
                                            child: Tooltip(
                                              message: "Join Chat",
                                              child: InkWell(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(13)),
                                                onTap: () async {
                                                  P2PChatGame? gameSettings =
                                                      await joinP2PChat(
                                                          context);
                                                  if (gameSettings != null) {
                                                    // switch to the game page and start as
                                                    gameSettings.initState =
                                                        P2PServerInitState
                                                            .join; // sets init state so GamePage knows to join another chat
                                                    await joinChat(
                                                        gameSettings, context);
                                                  }
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Icon(
                                                    Icons.call_merge_rounded,
                                                    size: 24,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: chatIconColor
                                                    .withOpacity(.18),
                                                border: Border.all(
                                                    color: chatIconColor),
                                                shape: BoxShape.circle),
                                            child: Tooltip(
                                              message: "New Chat",
                                              child: InkWell(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(13)),
                                                onTap: () {
                                                  hostChat();
                                                  // addConversation('chat');
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(9.0),
                                                  child: Image.asset(
                                                    'assets/images/new_msg.png',
                                                    width: 20,
                                                    height: 20,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 25,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
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
