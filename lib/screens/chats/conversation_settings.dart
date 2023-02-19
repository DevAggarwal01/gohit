import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:gohit/screens/chats/add_participants.dart';
import 'package:gohit/screens/profile_screen.dart';

import 'chat_screen.dart';

class ConversationSettings extends StatefulWidget {
  static const routeName = 'conversation-settings';

  @override
  State<ConversationSettings> createState() => _ConversationSettingsState();
}

class _ConversationSettingsState extends State<ConversationSettings> {
  types.Room? room;
  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Map<String, bool> isChanged = {'isLeaving': false};

  @override
  Widget build(BuildContext context) {
    room = ModalRoute.of(context)?.settings.arguments as types.Room;
    var mainUserId = FirebaseChatCore.instance.firebaseUser!.uid;
    String names = "";
    for (types.User x in room!.users) {
      if (x.id != mainUserId) {
        names += "${x.firstName}, ";
      }
    }
    names = names.substring(0, names.length - 2);
    List<Widget> userWidgets = [];
    room!.users.forEach((user) {
      if (user.id != mainUserId) {
        userWidgets.add(
          GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      user.firstName!,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.message_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () {
                      final room = FirebaseChatCore.instance
                          .createRoom(user)
                          .then((value) {
                        Navigator.of(context).pushNamed(ChatScreen.routeName,
                            arguments: {"room": value});
                      });
                    },
                  ),
                ],
              ),
            ),
            onTap: () async {
              Map userInfo = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.id)
                  .get()
                  .then((value) => value.data() as Map);
              Navigator.of(context)
                  .pushNamed(ProfileScreen.routeName, arguments: userInfo);
            },
          ),
        );
        userWidgets.add(
          const Divider(
            thickness: 1,
          ),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat Settings',
          style: Theme.of(context).textTheme.headline6,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, isChanged);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          SizedBox(height: 10),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Leave Chat',
                  style: TextStyle(color: Colors.red[900]),
                ),
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(
                    'Leave Chat',
                  ),
                  content: Text(
                      'Are you sure you would like to leave this conversation?'),
                  actions: [
                    TextButton(
                      child: Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: Text(
                        'LEAVE',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('rooms')
                            .doc(room!.id)
                            .update({
                          'userIds': FieldValue.arrayRemove([mainUserId])
                        });
                        isChanged['isLeaving'] = true;
                        Navigator.of(context).pop();
                        Navigator.pop(context, isChanged);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Divider(
            thickness: 1,
          ),
          if (room!.type == types.RoomType.group) ...[
            GestureDetector(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rename Chat',
                    style: TextStyle(color: Colors.red[900]),
                  ),
                ),
              ),
              onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (ctx) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 130),
                              child: Text(
                                'Edit Chat Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (controller.text.isEmpty) {
                                  return;
                                }
                                FirebaseFirestore.instance
                                    .collection('rooms')
                                    .doc(room!.id)
                                    .set(
                                  {'name': controller.text},
                                  SetOptions(merge: true),
                                );
                                Navigator.of(context).pop();
                                Navigator.of(context).pop(isChanged);
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Done',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          color: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty || value.trim().length < 5) {
                                return 'Please enter at least 5 characters.';
                              }
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            cursorColor: Colors.black,
                            autofocus: true,
                            style: TextStyle(color: Colors.black),
                            controller: controller,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelText: 'Enter chat name',
                              labelStyle: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
            Divider(
              thickness: 1,
            ),
          ],
          if (room!.type == types.RoomType.group) ...[
            GestureDetector(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add Participant',
                    style: TextStyle(color: Colors.red[900]),
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(AddParticipants.routeName, arguments: room);
              },
            ),
            Divider(
              thickness: 1,
            ),
          ],
          ...userWidgets,
        ],
      ),
    );
  }
}
