// provider/report_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/factory_report_model.dart';
import '../repositories/report_repository.dart';
import '../services/report_service.dart';


final reportServiceProvider = Provider((ref) => ReportService());

final reportRepositoryProvider = Provider((ref) {
  return ReportRepository(ref.read(reportServiceProvider));
});

final selectedDateProvider = StateProvider<String?>((ref) => null);
final filteredReportListProvider = FutureProvider<List<FactoryReportModel>>((ref) {
  final date = ref.watch(selectedDateProvider);
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getReportsByDate(date??'');});

