import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/user_details.dart';
import '../models/user_model.dart';

class ApiService {
  final String _baseUrl = "https://jsonplaceholder.typicode.com";

  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse("$_baseUrl/users"), headers: {'Content-Type': 'application/json', 'User-Agent': 'YourAppName/1.0'});
    if (response.statusCode == 200) {
      final List<dynamic> usersJson = json.decode(response.body);
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<UserDetail> getUserById(int id) async {
    final response = await http.get(Uri.parse("$_baseUrl/users/$id"), headers: {'Content-Type': 'application/json', 'User-Agent': 'YourAppName/1.0'});
    if (response.statusCode == 200) {
      return UserDetail.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user details');
    }
  }
}
