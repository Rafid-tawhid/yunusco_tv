// service/report_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/factory_report_model.dart';

class ReportService {
  final String baseUrl = 'https://yourapi.com/api';
  final List<FactoryReport> dummyFactoryList = [
    FactoryReport(
      title: 'Production',
      value: '512',
      change: '+3.5%',
      color: Colors.blue,
      icon: Icons.factory,
    ),
    FactoryReport(
      title: 'Efficiency',
      value: '87%',
      change: '+1.2%',
      color: Colors.green,
      icon: Icons.speed,
    ),
    FactoryReport(
      title: 'Downtime',
      value: '4.3 hrs',
      change: '-0.8%',
      color: Colors.red,
      icon: Icons.timer_off,
    ),
    FactoryReport(
      title: 'Quality',
      value: '98.2%',
      change: '+0.5%',
      color: Colors.purple,
      icon: Icons.verified,
    ),
    FactoryReport(
      title: 'Attendance',
      value: '93%',
      change: '-1.0%',
      color: Colors.orange,
      icon: Icons.groups,
    ),
    FactoryReport(
      title: 'Output',
      value: '1200 units',
      change: '+2.7%',
      color: Colors.teal,
      icon: Icons.auto_graph,
    ),
  ];


  Future<List<FactoryReport>> getAll() async{
    return dummyFactoryList;
  }

  Future<List<FactoryReport>> fetchReports() async {
    final response = await http.get(Uri.parse('$baseUrl/factory-reports'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // Convert actual API response
      return data.map((json) => FactoryReport.fromJson(json)).toList();
    }
    else {
      throw Exception('Failed to load factory reports');
    }
  }

}
