// service/report_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/employee_attendance_model.dart';
import '../models/factory_report_model.dart';
import '../models/input_issue_model.dart';

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

  Future<DepartmentData> getAllSectionAttendanceInfo(String date) async {

    final url = Uri.parse('${baseUrl}api/Dashboard/ProductionStregnth?date=$date');
    debugPrint('API Request: $url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      debugPrint('Response : ${response.body} ');
      final data = json.decode(response.body);

      final List<EmployeeAttendance> employees = (data['returnvalue'] as List)
          .map((a) => EmployeeAttendance.fromJson(a))
          .toList();
      debugPrint('employees ${employees.length}');

      // Create the grouped model
      final departmentData = DepartmentData.fromEmployeeList(employees);

      return departmentData;
    } else {
      throw Exception('Failed to load reports for date $date');
    }
  }


  Future<List<InputIssueModel>> getAllInputIssues(String date) async {

    final url = Uri.parse('${baseUrl}api/Dashboard/GetInputRelatedIssues?date=$date');
    debugPrint('API Request: $url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      debugPrint('Response : ${response.body} ');
      final data = json.decode(response.body);

      final List<InputIssueModel> input_issues = (data['returnvalue'] as List)
          .map((a) => InputIssueModel.fromJson(a))
          .toList();
      debugPrint('input_issues ${input_issues.length}');

      return input_issues;
    } else {
      throw Exception('Failed to load reports for date $date');
    }
  }


  Future<num> getMMR(String date) async {

    final url = Uri.parse('${baseUrl}api/Dashboard/GetMMRRatio?date=$date');
    debugPrint('API Request: $url');
    final response = await http.get(url);
    debugPrint("response.statusCode ${response.body}");
    if (response.statusCode == 200) {
      debugPrint('Response : ${response.body} ');
      final data = json.decode(response.body);

      return data['returnvalue'];
    } else {
      throw Exception('Failed to load reports for date $date');
    }
  }

}