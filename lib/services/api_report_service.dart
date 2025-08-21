import 'package:dio/dio.dart';

import '../models/employee_attendance_model.dart';
import '../models/factory_report_model.dart';
import '../models/input_issue_model.dart';
import '../models/shipment_info_model.dart';
import 'api_client.dart';

class ReportService {
  final Dio _dio = ApiClient().dio;

  Future<List<FactoryReportModel>> fetchReportsByDate(String date) async {
    // The .get() method returns a Response<dynamic>.
    // We await it and then access the .data property.
    final response = await _dio.get('/api/Finishing/ItemWiseEffi', queryParameters: {
      'ProductionDate': date,
    });

    // The JSON-parsed data is in response.data, not response itself.
    final data = response.data;
    return (data['Results'] as List)
        .map((json) => FactoryReportModel.fromJson(json))
        .toList();
  }

  Future<DepartmentData> getAllSectionAttendanceInfo(String date) async {
    final response = await _dio.get('/api/Dashboard/ProductionStregnth', queryParameters: {
      'date': date,
    });

    final data = response.data;
    final List<EmployeeAttendance> employees = (data['returnvalue'] as List)
        .map((json) => EmployeeAttendance.fromJson(json))
        .toList();

    return DepartmentData.fromEmployeeList(employees);
  }

  Future<List<InputIssueModel>> getAllInputIssues(String date) async {
    final response = await _dio.get('/api/Dashboard/GetInputRelatedIssues', queryParameters: {
      'date': date,
    });

    final data = response.data;
    return (data['returnvalue'] as List)
        .map((json) => InputIssueModel.fromJson(json))
        .toList();
  }

  Future<num> getMMR(String date) async {
    final response = await _dio.get('/api/Dashboard/GetMMRRatio', queryParameters: {
      'date': date,
    });

    final data = response.data;
    return data['returnvalue'];
  }

  Future<List<ShipmentInfoModel>> getShipmentDateInfo(String date1, String date2) async {
    final response = await _dio.get('/api/Dashboard/MonthlyTAndAAnalysis', queryParameters: {
      'FromDate': date1,
      'ToDate': date2,
    });

    final data = response.data;
    return (data['returnvalue'] as List)
        .map((json) => ShipmentInfoModel.fromJson(json))
        .toList();
  }
}