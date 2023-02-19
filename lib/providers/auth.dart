import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gohit/screens/authentication/more_signup_info.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;


class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? userId;
  String? username;
  final _auth = FirebaseAuth.instance;
  var fcmToken;
  late String email;
  late Map<String, dynamic> user;

  Future<void> updateUser() async {
    user = await FirebaseFirestore.instance.collection('users').doc(getUserID()).get().then((value) => value.data()!);
  }

  Future<Map> getUser(userId) async {
    return await FirebaseFirestore.instance.collection('users').doc(userId).get().then((value) => value.data()!);
  }
  // bool get isAuth {
  //   return token != null;
  // }

  // String? get token {
  //   if (_expiryDate != null &&
  //       _expiryDate!.isAfter(DateTime.now()) &&
  //       _token != null) {
  //     return _token;
  //   }
  // }

  // Future<void> signup(String username, String email, String password) async {
  //   // STORE NAME SOMEWHERE
  //   // Preferably make player class a provider, most likely this will be needed later on.
  //   return _authenticate(email, password, 'signUp');
  // }

  // Future<void> login(String email, String password) async {
  //   return _authenticate(email, password, 'signInWithPassword');
  // }

  // Future<void> _authenticate(
  //     String email, String password, String urlSegment) async {
  //   final url = Uri.parse(
  //       'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAFKf6pdgVSPXKE8FmFpT2kAAr6lnorXrA');
  //   try {
  //     final response = await http.post(
  //       url,
  //       body: json.encode(
  //         {
  //           'email': email,
  //           'password': password,
  //           'returnSecureToken': true,
  //         },
  //       ),
  //     );

  //     final responseData = json.decode(response.body);
  //     if (responseData['error'] != null) {
  //       throw HttpException(responseData['error']['message']);
  //     }
  //     // throw stops rest of code from executing
  //     _token = responseData['idToken'];
  //     _userId = responseData['localId'];
  //     _expiryDate = DateTime.now().add(
  //       Duration(
  //         seconds: int.parse(
  //           responseData['expiresIn'],
  //         ),
  //       ),
  //     );
  //     notifyListeners();
  //   } catch (error) {
  //     rethrow;
  //   }
  // }
  String getUserID() {
    return userId as String;
  }

  Future<void> submitAuthForm(String email, String password, String username,
      bool isLogin, BuildContext ctx) async {
    UserCredential authResult;
    bool isError = false;
    this.username = username;
    this.email = email;
    fcmToken = await FirebaseMessaging.instance.getToken();
    try {
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        userId = authResult.user!.uid;
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        userId = authResult.user!.uid;
        
      }
    } on FirebaseAuthException catch (error) {
      var message = 'An error occured, please check your credentials!';
      isError = true;


      if (error.message != null) {
        message = error.message as String;
      }
      _showErrorDialog(message, ctx);
    } catch (error) {
      print('error');
    }

    if (isLogin || isError) {
      return;
    }
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
