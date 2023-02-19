import 'dart:ui';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../providers/auth.dart';

class MoreSignUpInfo extends StatefulWidget {
  static final routeName = 'more-sign-up-info';
  const MoreSignUpInfo({Key? key}) : super(key: key);

  @override
  State<MoreSignUpInfo> createState() => _MoreSignUpInfoState();
}

class _MoreSignUpInfoState extends State<MoreSignUpInfo> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  late Map _authData;
  Map<String, dynamic> zipsIndexer = {};

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/zips_indexer.json');
    zipsIndexer = jsonDecode(response);
  }

  @override
  void initState() {
    readJson();
    super.initState();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    // setState(() {
    //   isLoading = true;
    // });

    _formKey.currentState!.save();
    int index = zipsIndexer[_authData['zipcode'].toString()];
    List<String> zips =
        (await rootBundle.loadString('assets/US_zips.txt')).split('\n'); // break up into lines
    
    List<String> zipcode = zips[index].split('\t'); // break up the line itself into elements

    double latitude = double.parse(zipcode[zipcode.length - 3]); // trick to get latitude and longitude
    double longitude = double.parse(zipcode[zipcode.length - 2]);

    await Provider.of<Auth>(context, listen: false).submitAuthForm(
      _authData['email'].trim(),
      _authData['password'].trim(),
      _authData['username'].trim(),
      false,
      context,
    );

    var mainUser = Provider.of<Auth>(context, listen: false);

    setState(() {
      isLoading = false;
    });
    bool working = true;
    try {
      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          firstName: mainUser.username,
          id: mainUser.getUserID(),
          metadata: {
            'email': mainUser.email,
            'fcmToken': mainUser.fcmToken,
            'zipcode': _authData['zipcode'],
            'ageGroup': _authData['ageGroup'],
            'yearsOfExperience': _authData['yearsOfExperience'],
            'userType': _authData['userType'],
            'aboutMe': 'Hey there! I am using GoHit.',
            'utr': '',
            'status': 'Looking to Hit',
            'latitude':latitude,
            'longitude':longitude,
          },
        ),
      );
    } catch (error) {
      working = false;
    }
    if (working) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Map arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    _authData = arguments;
    List<DropdownMenuItem<String>> dropdown = List.generate(
        30,
        (index) => DropdownMenuItem(
              child: Text(
                '${index * 3 + 6}-${index * 3 + 8}',
                style: GoogleFonts.sourceSansPro(
                  color: Colors.red[900],
                  fontWeight: FontWeight.w600,
                ),
              ),
              value: '${index * 3 + 6}-${index * 3 + 8}',
            ));
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
                    width: double.infinity,
                    child: Text(
                      'Add a few more details',
                      style: GoogleFonts.sourceSansPro(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextButton(
                    child: Text("Why do I need to provide this information?",
                        style: GoogleFonts.lato(
                            color: Colors.red[900], fontSize: 15)),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        // isScrollControlled: true,
                        builder: (BuildContext context) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Text(
                                  'Why does GoHit need this information?',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    '\nUsername: Necessary for the identification of user profiles.'),
                                Text(
                                    '\nZipcode: Needed to provide services including finding players and coaches NEAR YOU. This is assuming you would not like to matched to play with someone halfway across the country.'),
                                Text(
                                    '\nAge & Years of Experience: Needed to provide services including finding players near you that are approximately YOUR LEVEL'),
                                Text(
                                    '\nPlayer/Coach: Players are looking to hit with another or find a coach. Coaches are making themselves available to teach students'),
                                Text(
                                  '\nInformation is not used, manipulated, or shared in any way that benefits monetarily. All information is required to maintain functionality of GoHit.',
                                  style: GoogleFonts.lato(
                                      decoration: TextDecoration.underline),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Textbutton
                  SizedBox(height: 5),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w900),
                        decoration: InputDecoration(
                          labelText: 'USERNAME',
                          icon: Icon(Icons.person, color: Colors.black),
                          labelStyle: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty || value.trim().length < 5) {
                            return 'Please enter at least 5 characters.';
                          }
                        },
                        onSaved: (value) {
                          _authData['username'] = value;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w900),
                        decoration: InputDecoration(
                          labelText: 'ZIPCODE',
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
                          if (value!.isEmpty ||
                              value.length != 5 ||
                              double.tryParse(value) == null) {
                            return 'Zipcode must be 5 digits.';
                          } else if (zipsIndexer[value] == null) {
                            return 'Please enter a valid zipcode.';
                          }
                        },
                        onSaved: (value) {
                          _authData['zipcode'] = int.parse(value as String);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w900),
                        decoration: InputDecoration(
                          labelText: 'YEARS OF EXPERIENCE',
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
                          if (value!.isEmpty ||
                              value.length > 2 ||
                              double.tryParse(value) == null) {
                            return 'Please enter years of experience.';
                          }
                        },
                        onSaved: (value) {
                          _authData['yearsOfExperience'] =
                              int.parse(value as String);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField<String>(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your age group.';
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "What age group am I in?",
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                      ),
                      items: dropdown,
                      onChanged: (value) {
                        setState(() {
                          _authData['ageGroup'] = value;
                        });
                      }),
                  SizedBox(height: 10),
                  DropdownButtonFormField(
                      validator: (value) {
                        if (value == null) {
                          return 'Please select the optimal user experience.';
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "What type of tennis player am I?",
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                      ),
                      items: [
                        DropdownMenuItem(
                          child: Text(
                            'Player',
                            style: GoogleFonts.sourceSansPro(
                              color: Colors.red[900],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: 'player',
                        ),
                        DropdownMenuItem(
                          child: Text(
                            'Coach',
                            style: GoogleFonts.sourceSansPro(
                              color: Colors.red[900],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: 'coach',
                        )
                      ],
                      onChanged: (value) {
                        setState(() {
                          _authData['userType'] = value;
                        });
                      }),
                  Container(
                    margin: EdgeInsets.only(top: 40),
                    padding: EdgeInsets.only(left: 200),
                    height: isLoading ? null : 50,
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: Colors.red[900],
                          )
                        : ElevatedButton(
                            onPressed: _submit,
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
                                  'SIGN UP',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Icon(Icons.arrow_right_alt),
                              ],
                            ),
                          ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
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
