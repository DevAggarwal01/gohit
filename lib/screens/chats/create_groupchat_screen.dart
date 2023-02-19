import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:google_fonts/google_fonts.dart';

import '../profile_screen.dart';
import 'chat_screen.dart';

class CreateGroupChat extends StatefulWidget {
  const CreateGroupChat({Key? key}) : super(key: key);
  static const routeName = '/create-group-chat';

  @override
  State<CreateGroupChat> createState() => _CreateGroupChatState();
}

class _CreateGroupChatState extends State<CreateGroupChat> {
  TextEditingController userNameController = TextEditingController();
  bool searchSubmitted = false;
  List<types.User> chatParticipants = [];
  TextEditingController chatNameController = TextEditingController();

  @override
  void dispose() {
    userNameController.dispose();
    chatNameController.dispose();
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
        actions: [
          TextButton(
            onPressed: () {
              if (chatParticipants.length == 0) {
                return;
              }
              else if(chatParticipants.length == 1) {
                _showErrorDialog('Groups must have at least 3 participants', context);
                return;
              }
              getBottomModalSheet(
                  'Enter Group Name', 'Enter name', chatNameController,
                  (value) {
                if (value!.isEmpty || value.trim().length < 5) {
                  return 'Please enter at least 5 characters.';
                }
              }, () {
                Navigator.of(context).pop();
                FirebaseChatCore.instance.createGroupRoom(name: chatNameController.text, users: chatParticipants).then((value) {
                  Navigator.of(context).popAndPushNamed(ChatScreen.routeName,
                    arguments: {"room": value});
                });
              });
            },
            child: Text(
              'CREATE',
              style: GoogleFonts.roboto(
                  color: Colors.blue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
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
          if (chatParticipants.length > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 18, right: 18, top: 10),
                child: Text(
                  'Participants',
                  style: GoogleFonts.questrial(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      fontSize: 16),
                ),
              ),
            ),
          if (chatParticipants.length > 0)
            Container(
              height: 80,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: chatParticipants.map((user) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(3),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.red[900]),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            user.firstName!,
                            style: TextStyle(color: Colors.white),
                          ),
                          // SizedBox(width: 5),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              size: 28,
                            ),
                            onPressed: () {
                              setState(() {
                                chatParticipants.remove(user);
                              });
                            },
                          ),
                        ],
                      ),
                      onPressed: () {},
                    ),
                  );
                }).toList(),
                // getElevatedButton('Looking to Hit', Colors.black, 0),
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
              var peerUserMap = peerUser.toJson();
              Navigator.of(context)
                  .pushNamed(ProfileScreen.routeName, arguments: peerUserMap);
            },
            leading: CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(
              peerUser.firstName!,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            trailing: TextButton(
              child: Text(
                'ADD',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                chatParticipants.add(peerUser);
                userNameController.text = '';
                setState(() {
                  searchSubmitted = false;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> getBottomModalSheet(
      String header,
      String labelTextHint,
      TextEditingController controller,
      String? Function(String?) validate,
      Function func) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Text(
                      header,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      if (validate(controller.text) != null) {
                        return;
                      }
                      func();
                    },
                    child: Text(
                      'DONE',
                      style: GoogleFonts.roboto(
                          color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validate,
                  cursorColor: Colors.black,
                  style: GoogleFonts.lato(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  controller: controller,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: labelTextHint,
                    labelStyle: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          );
        });
  }
  void _showErrorDialog(String message, BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (ctx) => AlertDialog(
        title: Text(
          'An Error Occured!',
        ),
        content: Text(message),
        actions: [
          TextButton(
            child: Text(
              'OKAY',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
