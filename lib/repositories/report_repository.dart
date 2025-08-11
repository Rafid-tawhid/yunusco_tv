

import '../models/factory_report_model.dart';
import '../services/report_service.dart';

class ReportRepository {
  final ReportService service;

  ReportRepository(this.service);

  Future<List<FactoryReport>> getReports() => service.getAll();
}
