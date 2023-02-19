import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:gohit/screens/edit_profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var user;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _oldPasswordController = TextEditingController();
  var mainUser;
  int statusIndex = 0;
  String status = "";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _oldPasswordController.dispose();
    if(user['metadata']['status'] != status) {
      user['metadata']['status'] = status;
      FirebaseFirestore.instance.collection('users').doc(mainUser.getUserID()).update({'metadata.status':status});
    }
    super.dispose();
  }

  @override
  void initState() {
    mainUser = Provider.of<Auth>(context, listen: false);
    user = mainUser.user;
    status = user['metadata']['status'];
    // if statements to determine index WHEN IMPLIMENTING IN DATABASE
    if(status == "Looking to Hit") {
      statusIndex = 0;
    }
    else if(status == 'Looking for Students' || status == 'Looking for a Coach') {
      statusIndex = 1;
    }
    else {
      statusIndex = 2;
    }
    super.initState();
  }

  // EDIT ALL INFO IN METADATA
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40),
            Divider(thickness: 1),
            InkWell(
              child: Container(
                height: 80,
                child: Card(
                  elevation: 0,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 40,
                      child: Icon(
                        Icons.person,
                        size: 45,
                      ),
                    ),
                    title: Text(
                      user['firstName'],
                      style: GoogleFonts.questrial(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                    subtitle: Text(
                      // NEEDS REVAMP FOR OTHER PHONE SIZES
                      user['metadata']['userType'] == 'player'
                          ? 'Player'
                          : 'Coach',
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                    trailing: Text(
                      'Edit',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).pushNamed(EditProfileScreen.routeName);
              },
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            // status horizontal list view

            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 18, right: 18, top: 10),
                child: Text(
                  'My Status',
                  style: GoogleFonts.questrial(
                      fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              ),
            ),
            Container(
              height: 80,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  getElevatedButton('Looking to Hit', Colors.black, 0),
                  getElevatedButton(
                      user['metadata']['userType'] == 'player'
                          ? 'Looking for a Coach'
                          : 'Looking for Students',
                      Colors.red[900] as Color,
                      1),
                  getElevatedButton('Busy', Colors.blue, 2),
                ],
              ),
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            getListTile(
              Color.fromRGBO(37, 150, 190, 1),
              Icons.email,
              'Change Email',
              () {
                _emailController.text = '';
                getBottomModalSheet(
                  'Change Email',
                  'Enter email address',
                  _emailController,
                  (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Invalid email!';
                    }
                  },
                  () {
                    Navigator.of(context).pop();
                    _passwordController.text = '';
                    getBottomModalSheet('Verify Authentication With Password',
                        'Enter Password', _passwordController, (value) {
                      if (value!.isEmpty || value.length < 5) {
                        return 'Password is too short!';
                      }
                    }, () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                            'Change Email',
                          ),
                          content: Text(
                              'Are you sure you would like to change the email address linked to your account?\n\nYou will be unable to use the current email address next time you attempt to sign in.'),
                          actions: [
                            TextButton(
                              child: Text(
                                'CANCEL',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                _emailController.text = '';
                                _passwordController.text = '';
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text(
                                'CHANGE',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                try {
                                  UserCredential authResult = await FirebaseAuth
                                      .instance
                                      .signInWithEmailAndPassword(
                                          email: user['metadata']['email'],
                                          password: _passwordController.text);

                                  AuthCredential credential =
                                      EmailAuthProvider.credential(
                                          email: user['metadata']['email'],
                                          password: _passwordController
                                              .text); // reauthentication

                                  await FirebaseAuth.instance.currentUser!
                                      .reauthenticateWithCredential(
                                          credential); // reauthentication

                                  await authResult.user
                                      ?.updateEmail(_emailController.text);

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(mainUser.getUserID())
                                      .update({
                                    'metadata.email': _emailController.text
                                  });
                                  FirebaseAuth.instance.signOut();
                                  Navigator.of(context).pop();
                                } on FirebaseAuthException catch (error) {
                                  var message =
                                      'An error occured, please check your credentials!';

                                  if (error.message != null) {
                                    message = error.message as String;
                                  }
                                  _showErrorDialog(message, ctx);
                                } catch (error) {
                                  print(error);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    });
                  },
                );
              },
            ),
            Divider(thickness: 1),
            getListTile(Colors.teal, Icons.password, 'Change Password', () {
              _passwordController.text = '';
              _oldPasswordController.text = '';
              getBottomModalSheet(
                  'Change Password', 'Enter password', _passwordController,
                  (value) {
                if (value!.isEmpty || value.length < 5) {
                  return 'Password is too short!';
                }
              }, () {
                Navigator.of(context).pop();
                _oldPasswordController.text = '';
                getBottomModalSheet('Verify Authentication With Old Password',
                    'Enter password', _oldPasswordController, (value) {
                  if (value!.isEmpty || value.length < 5) {
                    return 'Password is too short!';
                  }
                }, () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        'Change Password',
                      ),
                      content: Text(
                          'Are you sure you would like to change the password linked to your account?\n\nYou will be unable to use the current password next time you attempt to sign in.'),
                      actions: [
                        TextButton(
                          child: Text(
                            'CANCEL',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            _passwordController.text = '';
                            _oldPasswordController.text = '';
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text(
                            'CHANGE',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            try {
                              UserCredential authResult = await FirebaseAuth
                                  .instance
                                  .signInWithEmailAndPassword(
                                      email: user['metadata']['email'],
                                      password: _oldPasswordController.text);

                              AuthCredential credential =
                                  EmailAuthProvider.credential(
                                      email: user['metadata']['email'],
                                      password: _oldPasswordController
                                          .text); // reauthentication
                              await FirebaseAuth.instance.currentUser!
                                  .reauthenticateWithCredential(
                                      credential); // reauthentication

                              await authResult.user
                                  ?.updatePassword(_passwordController.text);
                              FirebaseAuth.instance.signOut();
                              Navigator.of(context).pop();
                            } on FirebaseAuthException catch (error) {
                              var message =
                                  'An error occured, please check your credentials!';

                              if (error.message != null) {
                                message = error.message as String;
                              }
                              _showErrorDialog(message, ctx);
                            } catch (error) {
                              print(error);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                });
              });
            }),
            Divider(thickness: 1),
            getListTile(
              Colors.red,
              Icons.update,
              'Change User Experience',
              () {
                String userType = user['metadata']['userType'];
                return showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext ctx) {
                    return Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * .75,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                child: Text(
                                  'Change User Experience',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(ctx).pop();
                                  if (userType ==
                                      user['metadata']['userType']) {
                                    return;
                                  }
                                  user['metadata']['userType'] = userType;
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(mainUser.getUserID())
                                      .update({
                                    'metadata.userType': userType,
                                  });
                                  mainUser.user['metadata']['userType'] =
                                      userType;
                                },
                                child: Text(
                                  'SAVE',
                                  style: GoogleFonts.roboto(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            child: DropdownButtonFormField<String>(
                                // INCORPORATE THIS, ALONG WITH WITH INFO ABOUT WHAT IT MEANS TO BE PLAYER VS COACH, header 'Change User Experience' along with SAVE BUTTON sorta like conversation settings rename modal sheet
                                decoration: InputDecoration(
                                  labelText: 'User Type',
                                  labelStyle:
                                      GoogleFonts.questrial(color: Colors.grey),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                ),
                                style: GoogleFonts.questrial(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                items: [
                                  DropdownMenuItem(
                                    child: Text(
                                      'Player',
                                      style: GoogleFonts.questrial(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    value: 'player',
                                  ),
                                  DropdownMenuItem(
                                    child: Text(
                                      'Coach',
                                      style: GoogleFonts.questrial(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    value: 'coach',
                                  )
                                ],
                                value: userType,
                                onChanged: (value) {
                                  userType = value!;
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Text(
                              'Select user type that reflects desired user experience',
                              style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Text(
                              "A user of type 'Player' is, as the name implies, a tennis player. The main purpose of users who identify themselves as players in GoHit is to find other players with which to hit. Additionally, they may also use GoHit to find a coach willing to instruct them.",
                              style: GoogleFonts.lato(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Text(
                              "On the other hand, a user of type 'Coach' is a more experienced tennis player that is willing to teach others. Coaches may use this app to indicate to tennis players and potential students that they are open to teaching new students, given that they are contacted through the methods provided in GoHit.",
                              style: GoogleFonts.lato(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            Divider(
              thickness: 1,
            ),
            // email change
            // password change
            // both with a showBottomModalSheet()
            // inside the modal sheet, commence sign in and collection UserCredentials/authResult (similar to Auth class login)
            // authResult.user.HAS MANY METHODS
            SizedBox(height: 30),
            Divider(thickness: 1),
            TextButton(
              child: Text(
                'DELETE ACCOUNT',
                style: GoogleFonts.lato(
                    color: Colors.red[900],
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _passwordController.text = '';
                getBottomModalSheet('Verify Authentication With Password',
                    'Enter password', _passwordController, (value) {
                  if (value!.isEmpty || value.length < 5) {
                    return 'Password is too short!';
                  }
                }, () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        'Delete Account',
                      ),
                      content: Text(
                          'Are you sure you would like to delete your account? This action is irreversible.'),
                      actions: [
                        TextButton(
                          child: Text(
                            'CANCEL',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            _passwordController.text = '';
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text(
                            'DELETE',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            try {
                              UserCredential authResult = await FirebaseAuth
                                  .instance
                                  .signInWithEmailAndPassword(
                                      email: user['metadata']['email'],
                                      password: _passwordController.text);

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(mainUser.getUserID())
                                  .delete(); // delete from database

                              Set ids = {};
                              List docIdsToDelete = [];
                              var collection = FirebaseFirestore.instance
                                  .collection('rooms');
                              var roomsToDelete = await collection
                                  .where('userIds',
                                      arrayContains: mainUser.getUserID())
                                  .get();
                              var batch = FirebaseFirestore.instance.batch();

                              roomsToDelete.docs.forEach((document) {
                                if(document['type']=='group') {
                                  batch.update(collection.doc(document.id), {'userIds':FieldValue.arrayRemove([mainUser.userId])});
                                }
                                else {
                                  docIdsToDelete.add(document.id);
                                }
                                
                                (document['userIds'] as List)
                                    .forEach((element) {
                                  ids.add(element);
                                });
                              });

                              await batch.commit();

                              ids.remove(mainUser.getUserID());
                              // SEND NOTIFICATION SAYING '${Username} account deleted'

                              AuthCredential credential =
                                  EmailAuthProvider.credential(
                                      email: user['metadata']['email'],
                                      password: _passwordController
                                          .text); // reauthentication

                              await FirebaseAuth.instance.currentUser!
                                  .reauthenticateWithCredential(
                                      credential); // reauthentication

                              await authResult.user?.delete();
                              Navigator.of(context).pop();
                            } on FirebaseAuthException catch (error) {
                              var message =
                                  'An error occured, please check your credentials!';

                              if (error.message != null) {
                                message = error.message as String;
                              }
                              _showErrorDialog(message, ctx);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                });
              },
            ),
            Divider(thickness: 1),
          ],
        ),
      ),
    );
  }

  Widget getListTile(
      Color backgroundIconColor, IconData icon, String title, Function func) {
    return InkWell(
      child: Container(
        height: 60,
        child: Card(
          elevation: 0,
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(5.0), //or 15.0
              child: Container(
                height: 30.0,
                width: 30.0,
                color: backgroundIconColor,
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ),
        ),
      ),
      onTap: () {
        func();
      },
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
                      'SAVE',
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
                  style: GoogleFonts.questrial(
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

  Widget getElevatedButton(String text, Color backgroundColor, int index) {
    return Opacity(
      opacity: statusIndex == index ? 1 : .35,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(statusIndex == index ? 6 : 3),
            backgroundColor: MaterialStateProperty.all(backgroundColor),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            setState(() {
              statusIndex = index;
            });
            status = text;
          },
        ),
      ),
    );
  }
}
