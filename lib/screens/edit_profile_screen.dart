import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Map<String, dynamic>? user;
  TextEditingController userNameController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController yearsOfExperienceController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();
  String ageGroup = "";
  bool isLoadingSave = false;
  var mainUser;

  @override
  void dispose() {
    userNameController.dispose();
    zipcodeController.dispose();
    yearsOfExperienceController.dispose();
    aboutMeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // set controller initial values
    // prepare values
    var mainUser = Provider.of<Auth>(context, listen: false);
    user = mainUser.user;
    userNameController.text = user!['firstName'];
    zipcodeController.text = user!['metadata']['zipcode'].toString();
    yearsOfExperienceController.text =
        user!['metadata']['yearsOfExperience'].toString();
    aboutMeController.text = user!['metadata']['aboutMe'];
    ageGroup = user!['metadata']['ageGroup'];
    List<DropdownMenuItem<String>> dropdown = List.generate(
      30,
      (index) => DropdownMenuItem<String>(
        child: Text(
          '${index * 3 + 6}-${index * 3 + 8}',
          style: GoogleFonts.questrial(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        value: '${index * 3 + 6}-${index * 3 + 8}',
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
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
            onPressed: () async {
              // save controllers and other data here
              user!['firstName'] = userNameController.text;
              user!['metadata']['zipcode'] = int.parse(zipcodeController.text);
              user!['metadata']['yearsOfExperience'] =
                  int.parse(yearsOfExperienceController.text);
              user!['metadata']['aboutMe'] = aboutMeController.text;
              user!['metadata']['ageGroup'] = ageGroup;
              user!['updatedAt'] = Timestamp.fromDate(DateTime.now());
              setState(() {
                isLoadingSave = true;
              });
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(mainUser.getUserID())
                  .update({
                'firstName': user!['firstName'],
                'metadata.zipcode': user!['metadata']['zipcode'],
                'metadata.aboutMe': user!['metadata']['aboutMe'],
                'metadata.ageGroup': user!['metadata']['ageGroup'],
                'updatedAt': user!['updatedAt'],
              });
              mainUser.user = user!;
              setState(() {
                isLoadingSave = false;
              });
            },
            child: isLoadingSave
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  )
                : Text(
                    'SAVE',
                    style: GoogleFonts.roboto(
                        color: Colors.blue, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 30),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                child: Icon(
                  Icons.person,
                  size: 90,
                ),
              ),
              getTextFormFields(
                userNameController,
                'Username',
                (value) {
                  if (value!.isEmpty || value.trim().length < 5) {
                    return 'Please enter at least 5 characters.';
                  }
                },
              ),
              getTextFormFields(
                zipcodeController,
                'Zipcode',
                (value) {
                  if (value!.isEmpty ||
                      value.length != 5 ||
                      double.tryParse(value) == null) {
                    return 'Zipcode must be 5 digits.';
                  }
                },
              ),
              getTextFormFields(
                yearsOfExperienceController,
                'Years of Experience',
                (value) {
                  if (value!.isEmpty ||
                      value.length > 2 ||
                      double.tryParse(value) == null) {
                    return 'Please enter years of experience.';
                  }
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Cannot be empty.';
                    }
                  },
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  cursorColor: Colors.black,
                  style: GoogleFonts.questrial(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  controller: aboutMeController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelText: 'About Me',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your age group.';
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Age Group',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                style: GoogleFonts.questrial(
                    color: Colors.black, fontWeight: FontWeight.bold),
                items: dropdown,
                value: ageGroup,
                onChanged: (value) {
                  setState(() {
                    ageGroup = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTextFormFields(TextEditingController controller, String description,
      String? Function(String?) validate) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
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
          labelText: description,
          labelStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
