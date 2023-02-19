import 'package:flutter/material.dart';
import 'package:gohit/screens/chats/chat_screen.dart';
import 'package:gohit/screens/profile_screen.dart';
import 'package:gohit/screens/tabs_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class FindUsers extends StatefulWidget {
  static const routeName = '/find-users';

  @override
  State<FindUsers> createState() => _FindUsersState();
}

class _FindUsersState extends State<FindUsers> {
  String userType = "";

  int indexAddition = 0;

  int itemCountVar = 6; // CHANGE HERE TO CHANGE NUMBER OF LIST TILES PER PAGE, NO CHANGE TO LOGIC NEEDED

  Map user = {};
  Map<String, double> distancesFromMainUser = {};

  @override
  void initState() {
    var mainUser = Provider.of<Auth>(context, listen: false);
    user = mainUser.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userType = (ModalRoute.of(context)?.settings.arguments ?? '') as String;
    String userTypePlural;
    if (userType == 'player') {
      userTypePlural = 'Players';
    } else {
      userTypePlural = 'Coaches';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Find ${userTypePlural}',
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
      ),
      body: StreamBuilder<List<types.User>>(
        stream: FirebaseChatCore.instance.users(),
        initialData: const [],
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          List<types.User> findUsers = snapshot.data!
              .where((element) => element.metadata!['userType'] == userType)
              .toList();

          if(findUsers.isEmpty) { // cant still be null due to filtering
            return Center(child: CircularProgressIndicator());
          }
          // sort by distance from mainUser
          var distance = Distance();
          var mainUserLocation = LatLng(user['metadata']['latitude'], user['metadata']['longitude']);
          
          for (types.User user in findUsers) { // RECORDS DISTANCE FROM MAIN USER TO SAVE TIME AND DISCARD REPETIVE CALC
            double miles = distance.as(LengthUnit.Mile, mainUserLocation, LatLng(user.metadata!['latitude'], user.metadata!['longitude']));
            distancesFromMainUser[user.id] = miles;
          }

          findUsers.sort((user1, user2) { // SORTED
            if(distancesFromMainUser[user1.id]! < distancesFromMainUser[user2.id]!) {
              return -1;
            }
            else if(distancesFromMainUser[user1.id]! > distancesFromMainUser[user2.id]!) {
              return 1;
            }
            else {
              return 0;
            }
          }
          );
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'NEAREST YOU',
                                style: GoogleFonts.openSans(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              SizedBox(width: 15),
                              Tooltip(
                                triggerMode: TooltipTriggerMode.tap,
                                showDuration: Duration(seconds: 10),
                                message:
                                    'Closest players are at top of the list, and closest to default page',
                                child: Icon(Icons.info_outline),
                                padding: EdgeInsets.all(20),
                                margin: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.9),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                ),
                                textStyle: TextStyle(color: Colors.white),
                                preferBelow: true,
                                verticalOffset: 20,
                              )
                            ],
                          ),
                          Text(
                            'Click arrows to find other players',
                            style: GoogleFonts.questrial(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: (indexAddition == 0)
                                ? Colors.grey
                                : Colors.black,
                          ),
                          onPressed: () {
                            if (indexAddition == 0) {
                              return;
                            }
                            setState(() {
                              indexAddition -= 6;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: (findUsers.length - indexAddition <=
                                    itemCountVar)
                                ? Colors.grey
                                : Colors.black,
                          ),
                          onPressed: () {
                            if (findUsers.length - indexAddition <=
                                itemCountVar) {
                              return;
                            }
                            setState(() {
                              indexAddition += itemCountVar;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                if (findUsers.isEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 250),
                    child: Center(child: Text('No ${userType}s yet')),
                  ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount:
                      itemCountVar, // IMPORTANT - maybe make it a certain number like 10, which could be 10 profiles per page. Make this a global variable and add a set of arrows - clicking left subtracts 10 from itemCount variable (make sure it can't when at first index) and clicking right adds. Also, each user of the group of 10 can be found by doing findUser[index + itemCountVariable]
                  itemBuilder: (content, index) {
                    if (index + indexAddition >= findUsers.length) {
                      return const SizedBox(width: 0, height: 0);
                    }
                    return buildListTile(Icons.person_add_alt,
                        findUsers[index + indexAddition], context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildListTile(
      IconData leading, types.User peerUser, BuildContext context) {
    return Container(
      height: 95,
      margin: EdgeInsets.all(10),
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: ListTile(
            onTap: () {
              var peerUserMap = peerUser.toJson();
              Navigator.of(context)
                  .pushNamed(ProfileScreen.routeName, arguments: peerUserMap);
            },
            leading: Icon(
              leading,
              size: 40,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(
              peerUser.firstName!,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            subtitle: FittedBox(
              child: Text( distancesFromMainUser[peerUser.id] != 0 ?
                '${distancesFromMainUser[peerUser.id]} miles' : 'Closeby (same zipcode)',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.message_outlined,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () {
                final room = FirebaseChatCore.instance
                    .createRoom(peerUser)
                    .then((value) {
                  Navigator.of(context).pushNamed(ChatScreen.routeName,
                      arguments: {"room": value});
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
