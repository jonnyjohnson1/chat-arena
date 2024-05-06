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

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 90),
        () => setState((() => didInit = true)));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !didInit
        ? Container()
        : Column(
            children: [
              InkWell(
                onTap: () {
                  Conversation newConversation = Conversation(
                      id: Tools().getRandomString(10),
                      title: "Untitled",
                      lastMessage: "",
                      image: "images/userImage1.jpeg",
                      time: DateTime.now(),
                      primaryModel: 'Llama 2');
                  widget.conversations.value.insert(
                    0,
                    newConversation,
                  );
                  // ConversationDatabase.instance.create(newConversation);
                  setState(() {
                    widget.onTap(widget.conversations.value[0]);
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 10),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text("New Chat",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(
                      width: 5,
                    ),
                    Image.asset(
                      'assets/images/new_msg.png',
                      width: 20,
                      height: 20,
                    ),
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
                          itemCount: widget.conversations.value.length,
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(top: 4),
                          // physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ConversationListItem(
                              key: Key(widget.conversations.value[index].id),
                              conversation: widget.conversations.value[index],
                              onSelected: () {
                                widget.onTap(widget.conversations.value[index]);
                              },
                              onSettingsTap: () async {
                                // show alert dialog to clarify delete/clear
                                bool? deleteConfirmation =
                                    await showAlertDialog(context);
                                if (deleteConfirmation == true) {
                                  print("ID: " +
                                      widget.conversations.value[index].id);
                                  // delete from the conversations table
                                  // await ConversationDatabase.instance.delete(
                                  //     widget.conversations.value[index].id);
                                  // delete from the messages table
                                  // await ConversationDatabase.instance
                                  //     .deleteMessageByConvId(
                                  //         widget.conversations.value[index].id);
                                  widget.conversations.value.removeAt(index);
                                  widget.conversations.notifyListeners();
                                  widget.onDelete(true);
                                }
                              },
                              isMessageRead: true,
                            );
                          },
                        ),
                      );
                    }),
              ),
            ],
          );
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
