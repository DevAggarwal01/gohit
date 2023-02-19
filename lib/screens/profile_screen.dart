import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile-screen';
  Map user = {};
  Map<String, dynamic> mainUser = {};

  // should create a types.User variable in auth that has everything
  // DONT FORGET TO PASS AS ARGUEMENT IN tabsscreen

  @override
  Widget build(BuildContext context) {
    user = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{})
        as Map;
    var mainUserAuth = Provider.of<Auth>(context, listen: false);
    mainUser = mainUserAuth.user;
    var distance = Distance();
    double? miles;
    if (user != mainUser) {
      miles = distance.as(
          LengthUnit.Mile,
          LatLng(mainUser['metadata']['latitude'],
              mainUser['metadata']['longitude']),
          LatLng(user['metadata']['latitude'], user['metadata']['longitude']));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
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
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Container(
            color: Color.fromRGBO(175, 155, 70, 1),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      user['metadata']['status'],
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    user['metadata']['userType'] == 'player'
                        ? 'Player'
                        : 'Coach',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                buildImage(),
                SizedBox(height: 30),
                Center(
                  child: Text(
                    user['firstName'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white),
                  ),
                ),
                if (miles == null) const SizedBox(height: 30),
                if (miles != null)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        miles != 0
                            ? '${miles} miles away'
                            : 'Closeby (same zipcode)',
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          buildColumn(),
        ],
      ),
    );
  }

  Widget buildImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 128,
      ),
    );
  }

  List<Widget> buildStats() {
    var utr = user['metadata']['utr'];
    List<Widget> stats = [
      Text(
        'Years of Experience - ${user['metadata']['yearsOfExperience']}',
        style: TextStyle(fontSize: 24, color: Colors.grey),
      ),
      Text(
        'Age Group - ${user['metadata']['age']}',
        style: TextStyle(fontSize: 24, color: Colors.grey),
      ),
    ];
    if (!utr.isEmpty) {
      stats.insert(
        0,
        Text(
          'UTR - ${utr}',
          style: TextStyle(fontSize: 24, color: Colors.grey),
        ),
      );
    }
    return stats;
  }

  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(
          color: Colors.black,
        ),
      );

  Widget buildColumn() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'My Stats',
            style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.red[900]),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Years of Experience: ${user['metadata']['yearsOfExperience']}',
            style: GoogleFonts.openSans(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Age Group: ${user['metadata']['ageGroup']}',
            style: GoogleFonts.openSans(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w500),
          ),
          Divider(
            thickness: 1,
          ),
          SizedBox(height: 10),
          Text(
            'About Me',
            style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.red[900]),
          ),
          SizedBox(height: 10),
          Text(
            user['metadata']['aboutMe'],
            style: GoogleFonts.openSans(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
