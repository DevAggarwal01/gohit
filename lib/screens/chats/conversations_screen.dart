import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:gohit/screens/chats/chat_screen.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ConversationsScreen extends StatefulWidget {
  static const routeName = '/conversations-screen';

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  String mainUserID = FirebaseChatCore.instance.firebaseUser!.uid;


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<types.Room>>(
      stream: FirebaseChatCore.instance.rooms(
          orderByUpdatedAt:
              true),
      initialData: const [],
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var listOfConversations = snapshot.data!.where((element) => element.type == types.RoomType.direct);
        if (listOfConversations.isEmpty) {
          return Center(
            child: const Text('No chat rooms yet!'),
          );
        }
        return ListView(
          children: listOfConversations.map((e) {
            // ADD A WHERE STATEMENT HERE TO MAKE IT DIRECT CHATS ONLY WHILE GROUP CHATS ARE ON SEPARATE PAGE
            String names = "";
            for (types.User x in e.users) {
              if (x.id != mainUserID) {
                names += "${x.firstName}, ";
              }
            }
            if (names.length <= 1) {
              return const SizedBox(height: 0, width: 0);
            }
            names = names.substring(0, names.length - 2);

            return buildListTile(
                Icons.person,
                e.name!,
                "last message, if not then status",
                () => Navigator.of(context).pushNamed(ChatScreen.routeName,
                    arguments: {"room": e}),
                context);
          }).toList(),
        );
      },
    );
  }

  Widget buildListTile(IconData leading, String title, String subtitle,
      Function func, BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        child: Container(
          height: 95,
          margin: EdgeInsets.all(10),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: ListTile(
                leading: Icon(
                  leading,
                  size: 40,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  title,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                subtitle: FittedBox(
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
        ),
        onTap: () {
          func();
        },
      ),
    );
  }
}
