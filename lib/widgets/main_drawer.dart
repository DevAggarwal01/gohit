import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gohit/screens/authentication/login_screen.dart';
import 'package:gohit/screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/settings_screen.dart';
import '../screens/tabs_screen.dart';

class MainDrawer extends StatelessWidget {
  Widget buildListTile(String title, IconData icon, VoidCallback tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
        color: Colors.black,
      ),
      title: Text(title),
      onTap: tapHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 175,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
              ),
              child: Text(
                'Get out there!',
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    fontSize: 37,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          buildListTile(
            'Home',
            Icons.home_filled,
            () {
              Navigator.of(context).popAndPushNamed(TabsScreen.routeName);
            },
          ),
          buildListTile(
            'My Profile',
            Icons.person,
            () async {
              var mainUser = Provider.of<Auth>(context, listen: false);
              Navigator.of(context)
                  .pushNamed(ProfileScreen.routeName, arguments: mainUser.user);
            },
          ),
          buildListTile(
            'Settings',
            Icons.settings,
            () async {
              Navigator.of(context).pushNamed(SettingsScreen.routeName);
            },
          ),
          buildListTile(
            'Logout',
            Icons.logout,
            () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(Navigator.defaultRouteName, ModalRoute.withName(Navigator.defaultRouteName));
            },
          ),
        ],
      ),
    );
  }
}
