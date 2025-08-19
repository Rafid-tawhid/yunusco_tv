

import 'package:flutter/cupertino.dart';
import 'package:yunusco_ppt_tv/models/shipment_info_model.dart';

import '../models/employee_attendance_model.dart';
import '../models/factory_report_model.dart';
import '../models/input_issue_model.dart';
import '../services/api_report_service.dart';

class ReportRepository {
  final ReportService service;

  ReportRepository(this.service);

  // Existing method (keep for backward compatibility)
  //Future<List<FactoryReportModel>> getReports() => service.fetchReports();

  // New method with date parameter
  Future<List<FactoryReportModel>> getReportsByDate(String date) {
    debugPrint('DATE $date');
    return service.fetchReportsByDate(date);
  }


  Future<DepartmentData> getAllDeptAttandance(String date) {
    debugPrint('DATE $date');
    return service.getAllSectionAttendanceInfo(date);
  }

  Future<List<InputIssueModel>> getAllInputRelatedIssues(String date) {
    debugPrint('DATE $date');
    return service.getAllInputIssues(date);
  }


  Future<num> getMMR(String date) {
    debugPrint('MMR DATE $date');
    return service.getMMR(date);
  }

  Future<List<ShipmentInfoModel>> getShipmentDateInfo(String date1,String date2) {

    return service.getShipmentDateInfo(date1,date2);
  }

}
//

