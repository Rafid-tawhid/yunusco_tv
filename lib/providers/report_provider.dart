// provider/report_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_ppt_tv/models/shipment_info_model.dart';

import '../models/employee_attendance_model.dart';
import '../models/factory_report_model.dart';
import '../models/input_issue_model.dart';
import '../repositories/report_repository.dart';
import '../services/api_report_service.dart';


// ====== Services & Repositories ======
final reportServiceProvider = Provider<ReportService>((ref) => ReportService());
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.read(reportServiceProvider));
});

// ====== Date Management ======
final selectedDateProvider = StateProvider<String>((ref) {
  return DateTime.now().toIso8601String().split('T').first; // yyyy-MM-dd
});

// ====== Data Providers ======
// 1. MMR (Machine Maintenance Rate)
final mmrProvider = FutureProvider<num>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  final date = ref.watch(selectedDateProvider);
  return repo.getMMR(date);
});

// 2. Factory Reports List
final filteredReportListProvider = FutureProvider<List<FactoryReportModel>>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  final date = ref.watch(selectedDateProvider);
  return repo.getReportsByDate(date);
});

// 3. Input Issues List
final inputIssuesProvider = FutureProvider<List<InputIssueModel>>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  final date = ref.watch(selectedDateProvider);
  return repo.getAllInputRelatedIssues(date);
});

// 4. Department Attendance (NEW)
final departmentAttendanceProvider = FutureProvider<DepartmentData>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  final date = ref.watch(selectedDateProvider);
  return repo.getAllDeptAttandance(date);
});
//5. Shipment info
final shipmentInfoProvider = FutureProvider<List<ShipmentInfoModel>>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  // final date = ref.watch(selectedDateProvider);
  return repo.getShipmentDateInfo('date','date');
});