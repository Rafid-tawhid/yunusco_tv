
// Date provider (you can set this from a DatePicker, etc.)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_ppt_tv/models/input_issue_model.dart';

import '../models/employee_attendance_model.dart';
import '../repositories/report_repository.dart';
import '../services/report_service.dart';

final selectedDateProvider2 = StateProvider<String>((ref) {
  return DateTime.now().toIso8601String().split('T').first; // yyyy-MM-dd
});

// Provide ReportService
final reportServiceProvider2 = Provider<ReportService>((ref) {
  return ReportService();
});

// Provide ReportRepository
final reportRepositoryProvider2 = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.watch(reportServiceProvider2));
});

// Department Attendance FutureProvider
final departmentAttendanceProvider = FutureProvider<DepartmentData>((ref) {
  final date = ref.watch(selectedDateProvider2);
  final repo = ref.watch(reportRepositoryProvider2);
  return repo.getAllDeptAttandance(date);
});



