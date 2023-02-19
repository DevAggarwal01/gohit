import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:gohit/screens/chats/conversation_settings.dart';
import 'package:gohit/screens/chats/conversations_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/auth.dart';
import '../tabs_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  static const routeName = '/chat-screen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  types.User _user =
      types.User(id: FirebaseChatCore.instance.firebaseUser!.uid);
  List<types.Message> _messages = [];
  var room;
  Map<String, bool> isChanged = {};

  void notifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );
  }

  @override
  void initState() {
    notifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    room = arguments['room'];
    String names = "";
    String mainUserName = "";
    for (types.User x in room.users) {
      if (x.id != _user.id) {
        names += "${x.firstName}, ";
      } else {
        mainUserName = x.firstName!;
      }
    }
    names = names.substring(0, names.length - 2);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          room.name,
          style: Theme.of(context).textTheme.headline6,
        ),
        leading: IconButton(
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.black,
            ),
            onPressed: () async {
              // returns whether or not user chose to leave conversation
              isChanged = await Navigator.of(context).pushNamed(
                  ConversationSettings.routeName,
                  arguments: room) as Map<String, bool>;
              if (isChanged['isLeaving'] == true) {
                List remainingIds = [];
                for (types.User x in room.users) {
                  if (x.id != _user.id) {
                    remainingIds.add(x.id);
                  }
                }
                String message = '${mainUserName} has left the chat';
                // SEND MANUAL NOTIFICATION to remainingUsers SAYING the message above

                if(room.type == types.RoomType.direct) {
                  FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(room.id)
                    .delete();
                }
                
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<types.Room>(
        initialData: room,
        stream: FirebaseChatCore.instance.room(room.id),
        builder: (context, snapshot) => StreamBuilder<List<types.Message>>(
          initialData: const [],
          stream: FirebaseChatCore.instance.messages(snapshot.data!), // gonna be exception here if leave empty conversation, but it still works just fine
          builder: (context, snapshot) => Chat(
            messages: snapshot.data ?? [],
            onSendPressed: _handleSendPressed,
            user: _user,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          ),
        ),
      ),
    );
  }

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  void _handleSendPressed(types.PartialText message) {
    // final textMessage = types.TextMessage(
    //   author: _user,
    //   createdAt: DateTime.now().millisecondsSinceEpoch,
    //   id: randomString(),
    //   text: message.text,
    // );

    // _addMessage(textMessage);
    FirebaseChatCore.instance.sendMessage(
      message,
      room.id,
    );
    // _sendNotification();
  }

  void _sendNotification() async {
    final result = await FirebaseFunctions.instance
        .httpsCallable('sendNotification')
        .call();
  }
}
