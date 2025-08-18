// Provider for the repository
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_ppt_tv/services/report_service.dart';

import '../models/shipment_info_model.dart';
import '../repositories/report_repository.dart';
import 'item_provider.dart';

final ReportRepositoryProvider = Provider<ReportService>((ref) => ReportService());
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.read(ReportRepositoryProvider));
});


// StateNotifier for managing shipment data
class ShipmentNotifier extends StateNotifier<AsyncValue<List<ShipmentInfoModel>>> {
  final ReportService repository;

  ShipmentNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> fetchShipments(String date1, String date2) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getShipmentDateInfo(date1, date2));
  }
}

// Provider for the StateNotifier
final shipmentProvider = StateNotifierProvider<ShipmentNotifier, AsyncValue<List<ShipmentInfoModel>>>((ref) {
  final repository = ref.read(ReportRepositoryProvider);
  return ShipmentNotifier(repository);
});