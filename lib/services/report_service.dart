// service/report_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/factory_report_model.dart';

class ReportService {
  final String baseUrl = 'http://202.74.243.118:8090/';
  final List<FactoryReportModel> dummyFactoryList = [];


  Future<List<FactoryReportModel>> getAll() async{
    return dummyFactoryList;
  }

  Future<List<FactoryReportModel>> fetchReports() async {
    final response = await http.get(Uri.parse('${baseUrl}api/Finishing/ItemWiseEffi'));
    debugPrint('Server Response : ${response.body}');
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<FactoryReportModel> reportList=[];
      for(var i in data['Results']){
        reportList.add(FactoryReportModel.fromJson(i));
      }
      debugPrint('reportList ${reportList.length}');
      // Convert actual API response
      return reportList;
    }
    else {
      throw Exception('Failed to load factory reports');
    }
  }

}
