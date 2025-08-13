// service/report_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/factory_report_model.dart';

class ReportService {
  final String baseUrl = 'http://202.74.243.118:8090/';

  Future<List<FactoryReportModel>> fetchReportsByDate(String date) async {
    final url = Uri.parse('${baseUrl}api/Finishing/ItemWiseEffi?ProductionDate=$date');

    debugPrint('API Request: $url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['Results'] as List)
          .map((i) => FactoryReportModel.fromJson(i))
          .toList();
    } else {
      throw Exception('Failed to load reports for date $date');
    }
  }
}