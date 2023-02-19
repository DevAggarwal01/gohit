import 'package:flutter/material.dart';
import 'package:gohit/screens/authentication/more_signup_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

import '../../providers/auth.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/sign-up';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final _passwordController = TextEditingController();

  Map _authData = { // NOT REFLECTIVE OF EVERYTHING SENT TO DATABASE
    'email': '',
    'password': '',
    'username': '',
    'zipcode':'',
    'userType': '',
    'yearsOfExperience':'',
    'ageGroup':'',
  };

  Future<void> _nextPage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    _formKey.currentState!.save();

    Navigator.of(context).pushNamed(MoreSignUpInfo.routeName, arguments: _authData);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          bottomOpacity: 0.0,
          elevation: 0.0,
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
        body: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 25),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 100),
                    width: double.infinity,
                    child: Text(
                      'Create Account',
                      style: GoogleFonts.sourceSansPro(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Text(
                      'Let\'s get started!',
                      style: GoogleFonts.sourceSansPro(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 50),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w900),
                        decoration: InputDecoration(
                          labelText: 'EMAIL',
                          icon: Icon(Icons.email, color: Colors.black),
                          labelStyle: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Invalid email!';
                          }
                        },
                        onSaved: (value) {
                          _authData['email'] = value as String;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // Card(
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(horizontal: 10),
                  //     child: TextFormField(
                  //       style: TextStyle(
                  //           color: Colors.black, fontWeight: FontWeight.w900),
                  //       decoration: InputDecoration(
                  //         labelText: 'USERNAME',
                  //         icon: Icon(Icons.person, color: Colors.black),
                  //         labelStyle: TextStyle(
                  //             color: Colors.black, fontWeight: FontWeight.bold),
                  //         enabledBorder:
                  //             OutlineInputBorder(borderSide: BorderSide.none),
                  //         focusedBorder:
                  //             OutlineInputBorder(borderSide: BorderSide.none),
                  //       ),
                  //       cursorColor: Colors.black,
                  //       keyboardType: TextInputType.name,
                  //       textInputAction: TextInputAction.next,
                  //       validator: (value) {
                  //         if (value!.isEmpty || value.length < 5) {
                  //           return 'Please enter at least 5 characters.';
                  //         }
                  //       },
                  //       onSaved: (value) {
                  //         _authData['username'] = value;
                  //       },
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w900),
                        decoration: InputDecoration(
                          labelText: 'PASSWORD',
                          icon: Icon(Icons.lock, color: Colors.black),
                          labelStyle: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                        obscureText: true,
                        cursorColor: Colors.black,
                        textInputAction: TextInputAction.next,
                        controller: _passwordController,
                        validator: (value) {
                          if (value!.isEmpty || value.length < 5) {
                            return 'Password is too short!';
                          }
                        },
                        onSaved: (value) {
                          _authData['password'] = value;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w900),
                        decoration: InputDecoration(
                          labelText: 'CONFIRM PASSWORD',
                          icon: Icon(Icons.lock, color: Colors.black),
                          labelStyle: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                        obscureText: true,
                        cursorColor: Colors.black,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match!';
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 40),
                    padding: EdgeInsets.only(left: 200),
                    height: isLoading ? null : 50,
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: Colors.red[900],
                          )
                        : ElevatedButton(
                            onPressed: _nextPage,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.tertiary),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'NEXT',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Icon(Icons.arrow_right_alt),
                              ],
                            ),
                          ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 75),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
