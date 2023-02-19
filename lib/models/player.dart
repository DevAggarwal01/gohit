import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Player {
  String id;
  String username;
  int zipcode = 0;
  String email;
  String bio = ''; // ABOUT ME SECTION

  Player({required this.id, required this.username, required this.email});

  factory Player.fromMap(Map<String, dynamic> data) {
    return Player(
        id: data['id'], username: data['username'], email: data['email']);
  }

}
