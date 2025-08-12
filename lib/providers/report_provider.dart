// provider/report_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/factory_report_model.dart';
import '../repositories/report_repository.dart';
import '../services/report_service.dart';


final reportServiceProvider = Provider((ref) => ReportService());

final reportRepositoryProvider = Provider((ref) {
  return ReportRepository(ref.read(reportServiceProvider));
});

final reportListProvider = FutureProvider<List<FactoryReportModel>>((ref) {
  return ref.read(reportRepositoryProvider).getReports();
});
