

import 'package:flutter/cupertino.dart';

import '../models/factory_report_model.dart';
import '../services/report_service.dart';

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
}