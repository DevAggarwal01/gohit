import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gohit/screens/chats/chat_screen.dart';
import 'package:gohit/screens/chats/create_conversation.dart';
import 'package:gohit/screens/chats/create_groupchat_screen.dart';
import 'package:gohit/screens/chats/groupchat_screen.dart';
import 'package:gohit/screens/settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import 'chats/conversations_screen.dart';
import './profile_screen.dart';
import './reminders_screen.dart';
import './go_hit_screen.dart';
import '../widgets/main_drawer.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs';
  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  // screens with a bottom navigation bar
  List<Map<String, Object>> _pages = [
    {"": ""}
  ];

  void asyncMethod() async {
    var mainUser = Provider.of<Auth>(context, listen: false);
    mainUser.userId = FirebaseAuth.instance.currentUser!.uid;
    await mainUser.updateUser();
  }

  @override
  void initState() {
    _pages = [
      {'page': GoHitScreen(), 'title': 'GoHit'},
      {'page': ConversationsScreen(), 'title': 'Chats'},
      {'page': GroupChatScreen(), 'title': 'Groups'},
      {'page': RemindersScreen(), 'title': 'Reminders'},
      {'page': 'drawer', 'title': 'More'}, // dummy data, just for drawer index
    ];
    asyncMethod();
    super.initState();
  }

  int _selectedPageIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _selectPage(int index) {
    setState(() {
      if (index == 4 && _scaffoldKey.currentState != null) {
        // open drawer but do not switch screen if drawer selected
        _scaffoldKey.currentState!.openEndDrawer();
      } else if (index < 4) {
        _selectedPageIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Map arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    if (arguments.isNotEmpty) {
      _selectedPageIndex = arguments['startIndex'];
      arguments.remove("startIndex");
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _pages[_selectedPageIndex]['title'] as String,
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: const [
          Visibility(visible: false, child: Icon(Icons.abc)),
        ], // hide drawer icon on app bar
      ),
      body: _pages[_selectedPageIndex]['page'] as Widget,
      endDrawer: MainDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        currentIndex: _selectedPageIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // REPLACE WITH TENNIS BALL
            label: 'GoHit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat_rounded),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons
                .edit_calendar_outlined), // REPLACE WITH A BELL - REMINDERS ICON
            activeIcon: Icon(Icons.edit_calendar_rounded),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
      floatingActionButton: (_selectedPageIndex == 1 || _selectedPageIndex == 2)
          ? FloatingActionButton(
              backgroundColor: Colors.red[900],
              child: Icon(
                Icons.add,
                size: 32,
              ),
              onPressed: () {
                if(_selectedPageIndex==1) {
                  Navigator.of(context).pushNamed(CreateConversation.routeName);
                }
                else {
                  Navigator.of(context).pushNamed(CreateGroupChat.routeName);
                }
              },
            )
          : null,
    );
  }
}
