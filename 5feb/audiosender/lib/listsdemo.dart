import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class News {
  final int id;
  final String email;
  final String avatar;

  News(
      {
      this.id,
      this.avatar,
      this.email
      });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
        id: json["id"] as int,
        email: json["email"] as String,
        avatar: json["avatar"] as String
    );
  }
}

Future<List<News>> fetchData(http.Client client) async {
  final response = await client.get('https://reqres.in/api/users?page=2');
  return compute(parseData, response.body);
}

List<News> parseData(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed['data'].map<News>((json) => News.fromJson(json)).toList();
}
