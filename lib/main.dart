import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gohit/screens/authentication/more_signup_info.dart';
import 'package:gohit/screens/chats/add_participants.dart';
import 'package:gohit/screens/chats/chat_screen.dart';
import 'package:gohit/screens/chats/conversation_settings.dart';
import 'package:gohit/screens/chats/create_conversation.dart';
import 'package:gohit/screens/chats/create_groupchat_screen.dart';
import 'package:gohit/screens/chats/groupchat_screen.dart';
import 'package:gohit/screens/edit_profile_screen.dart';
import 'package:gohit/screens/find_users.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './screens/settings_screen.dart';
import 'screens/chats/conversations_screen.dart';
import './screens/profile_screen.dart';
import './screens/reminders_screen.dart';
import './screens/tabs_screen.dart';
import './screens/go_hit_screen.dart';
import 'screens/authentication/login_screen.dart';
import 'screens/authentication/signup_screen.dart';
import './providers/auth.dart';
import './firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
    ],
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => Auth()),
        ],
        child: Consumer<Auth>(
          builder: (_, auth, child) => MaterialApp(
            title: 'Flutter Demo',
            /*theme: ThemeData(
              colorScheme: ColorScheme(
                brightness: Brightness.light,
                primary: Colors.black,
                onPrimary: Colors.yellow,
                secondary: Colors.yellow,
                onSecondary: Colors.black,
                error: Colors.red,
                onError: Colors.white,
                surface: Colors.green,
                onSurface: Colors.white,
                background: Colors.black,
                onBackground: Colors.yellow,
              ),
              canvasColor: Colors.yellow[300], */
            theme: ThemeData(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.white,
                  secondary: Colors.black,
                  tertiary: Colors.red[900]),
              canvasColor: Colors.white,
              textTheme: TextTheme(
                subtitle1: GoogleFonts.openSans(
                  textStyle: TextStyle(
                      color: Colors.red[900], fontWeight: FontWeight.w600),
                ),
                subtitle2: GoogleFonts.sourceSans3(
                  textStyle:
                      TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                ),
                headline6: GoogleFonts.lato(
                  textStyle: TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return TabsScreen();
                } else {
                  return LoginScreen();
                }
              },
            ),
            routes: {
              TabsScreen.routeName: (ctx) => TabsScreen(),
              GoHitScreen.routeName: (ctx) => GoHitScreen(),
              ConversationsScreen.routeName: (ctx) => ConversationsScreen(),
              RemindersScreen.routeName: (ctx) => RemindersScreen(),
              ProfileScreen.routeName: (ctx) => ProfileScreen(),
              SettingsScreen.routeName: (ctx) => SettingsScreen(),
              LoginScreen.routeName: (ctx) => LoginScreen(),
              SignUpScreen.routeName: (ctx) => SignUpScreen(),
              FindUsers.routeName: (ctx) => FindUsers(),
              ChatScreen.routeName: (ctx) => ChatScreen(),
              MoreSignUpInfo.routeName: (ctx) => MoreSignUpInfo(),
              ConversationSettings.routeName: (ctx) => ConversationSettings(),
              EditProfileScreen.routeName: (ctx) => EditProfileScreen(),
              CreateConversation.routeName: (context) => CreateConversation(),
              GroupChatScreen.routeName : (context) => GroupChatScreen(),
              CreateGroupChat.routeName: (context) => CreateGroupChat(),
              AddParticipants.routeName:(context) => AddParticipants(),
            },
          ),
        ),
      ),
    );
  }
}
