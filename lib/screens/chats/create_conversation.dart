import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:google_fonts/google_fonts.dart';

import '../profile_screen.dart';
import 'chat_screen.dart';

class CreateConversation extends StatefulWidget {
  const CreateConversation({Key? key}) : super(key: key);
  static const routeName = '/create-conversation';

  @override
  State<CreateConversation> createState() => _CreateConversationState();
}

class _CreateConversationState extends State<CreateConversation> {
  TextEditingController userNameController = TextEditingController();
  bool searchSubmitted = false;

  @override
  void dispose() {
    userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Chat',
          style: Theme.of(context).textTheme.headline6,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () {},
        //     child: Text(
        //       'CREATE',
        //       style: GoogleFonts.roboto(
        //           color: Colors.blue, fontWeight: FontWeight.w600),
        //     ),
        //   ),
        // ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'ADD PLAYERS',
              style: GoogleFonts.openSans(
                color: Colors.red[900],
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          Card(
            elevation: 2,
            child: TextFormField(
              cursorColor: Colors.blue,
              style: GoogleFonts.lato(color: Colors.black),
              controller: userNameController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search by username",
                hintStyle: GoogleFonts.lato(color: Colors.grey),
                contentPadding: EdgeInsets.all(20),
                fillColor: Colors.grey[200],
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
              ),
              onFieldSubmitted: ((value) {
                setState(() {
                  searchSubmitted = true;
                });
              }),
            ),
          ),
          if (searchSubmitted)
            StreamBuilder<List<types.User>>(
                stream: FirebaseChatCore.instance.users(),
                initialData: const [],
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }
                  List<types.User> findUsers = snapshot.data!
                      .where(
                        (element) =>
                            element.firstName!.toLowerCase() ==
                            userNameController.text.toLowerCase(),
                      )
                      .toList();

                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: findUsers.length,
                      itemBuilder: (context, index) {
                        return buildListTile(findUsers[index], context);
                      });
                })
        ],
      ),
    );
  }

  Widget buildListTile(types.User peerUser, BuildContext context) {
    return Container(
      height: 90,
      margin: EdgeInsets.all(10),
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: Align(
          alignment: Alignment.center,
          child: ListTile(
            onTap: () {
              final room =
                  FirebaseChatCore.instance.createRoom(peerUser).then((value) {
                Navigator.of(context).popAndPushNamed(ChatScreen.routeName,
                    arguments: {"room": value});
              });
            },
            leading: IconButton(
              icon: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              onPressed: () {
                var peerUserMap = peerUser.toJson();
                Navigator.of(context)
                    .pushNamed(ProfileScreen.routeName, arguments: peerUserMap);
              },
            ),
            title: Text(
              peerUser.firstName!,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}
