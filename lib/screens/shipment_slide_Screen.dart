import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/shipment_info_model.dart';
import '../providers/shipment_provider.dart';

class ShipmentInfoScreen extends ConsumerStatefulWidget {
  const ShipmentInfoScreen({super.key});

  @override
  ConsumerState<ShipmentInfoScreen> createState() => _ShipmentInfoScreenState();
}

class _ShipmentInfoScreenState extends ConsumerState<ShipmentInfoScreen> {
  final TextEditingController _date1Controller = TextEditingController();
  final TextEditingController _date2Controller = TextEditingController();
  bool _initialFetchDone = false;

  @override
  void initState() {
    super.initState();
    // Set default dates (e.g., current month)
    final now = DateTime.now();
    _date1Controller.text = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
    _date2Controller.text = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month + 1, 0));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialFetchDone) {
      _initialFetchDone = true;
      _fetchDataIfNeeded();
    }
  }

  Future<void> _fetchDataIfNeeded() async {
    final currentState = ref.read(shipmentProvider);
    if (currentState.value == null || currentState.value!.isEmpty) {
      await ref.read(shipmentProvider.notifier).fetchShipments(
        _date1Controller.text,
        _date2Controller.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipmentState = ref.watch(shipmentProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('Shipment Info',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _date1Controller,
                    decoration: const InputDecoration(
                      labelText: 'From Date (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, _date1Controller),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _date2Controller,
                    decoration: const InputDecoration(
                      labelText: 'To Date (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, _date2Controller),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    ref.read(shipmentProvider.notifier).fetchShipments(
                      _date1Controller.text,
                      _date2Controller.text,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: shipmentState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (shipments) {
                  if (shipments.isEmpty) {
                    return const Center(child: Text('No shipment data available'));
                  }
                  return ListView.builder(
                    itemCount: shipments.length,
                    itemBuilder: (context, index) {
                      final shipment = shipments[index];
                      return Card(
                        elevation: 4,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Month Header
                              Text(
                                shipment.monthYear ?? 'N/A',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Pie Chart and Stats Side by Side
                              Row(
                                children: [
                                  // Pie Chart
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 400,
                                      child: _buildDeliveryPieChart(shipment),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Stats
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildEnhancedInfoRow('Total Order', (shipment.delivered!+shipment.notDelivered!), Colors.black),
                                        _buildEnhancedInfoRow('Delivered', shipment.delivered, Colors.green),
                                        _buildEnhancedInfoRow('Not Delivered', shipment.notDelivered, Colors.red),
                                        _buildEnhancedInfoRow('Before Shipped', shipment.beforeShiped, Colors.blue),
                                        _buildEnhancedInfoRow('Timely Shipped', shipment.timelyShiped, Colors.teal),
                                        _buildEnhancedInfoRow('1 Week Delay', shipment.oneWeekDelay, Colors.orange),
                                        _buildEnhancedInfoRow('2 Week Delay', shipment.twoWeekDelay, Colors.deepOrange),
                                        _buildEnhancedInfoRow('>2 Week Delay', shipment.moreTwoWeekDelay, Colors.purple),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

  }
  _buildDeliveryPieChart(ShipmentInfoModel shipment) {
    final total = (shipment.delivered ?? 0) +
        (shipment.notDelivered ?? 0) +
        (shipment.beforeShiped ?? 0) +
        (shipment.timelyShiped ?? 0);

    if (total == 0) {
      return const Center(child: Text('No data available'));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 100,
        sections: [
          PieChartSectionData(
            value: (shipment.delivered ?? 0).toDouble(),
            color: Colors.green,
            title: '${((shipment.delivered ?? 0) / total * 100).toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: (shipment.notDelivered ?? 0).toDouble(),
            color: Colors.red,
            title: '${((shipment.notDelivered ?? 0) / total * 100).toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: (shipment.beforeShiped ?? 0).toDouble(),
            color: Colors.blue,
            title: '${((shipment.beforeShiped ?? 0) / total * 100).toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: (shipment.timelyShiped ?? 0).toDouble(),
            color: Colors.teal,
            title: '${((shipment.timelyShiped ?? 0) / total * 100).toStringAsFixed(1)}%',
            radius: 20,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedInfoRow(String label, num? value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value?.toString() ?? '0',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  void dispose() {
    _date1Controller.dispose();
    _date2Controller.dispose();
    super.dispose();
  }
}

