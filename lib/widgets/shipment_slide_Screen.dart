import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../models/shipment_info_model.dart';
import '../providers/shipment_provider.dart';

class ShipmentInfoScreen extends ConsumerStatefulWidget {
  const ShipmentInfoScreen({super.key});

  @override
  ConsumerState<ShipmentInfoScreen> createState() => _ShipmentInfoScreenState();
}

class _ShipmentInfoScreenState extends ConsumerState<ShipmentInfoScreen> {
  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<int> years = List.generate(3, (index) => DateTime.now().year - 2 + index);

  String? selectedMonth;
  int? selectedYear;
  bool _initialFetchDone = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = months[now.month - 1];
    selectedYear = now.year;
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
      await _fetchShipmentData();
    }
  }

  Future<void> _fetchShipmentData() async {
    if (selectedMonth == null || selectedYear == null) return;

    final monthIndex = months.indexOf(selectedMonth!) + 1;
    final firstDay = DateTime(selectedYear!, monthIndex, 1);
    final lastDay = DateTime(selectedYear!, monthIndex + 1, 0);

    await ref.read(shipmentProvider.notifier).fetchShipments(
      DateFormat('yyyy-MM-dd').format(firstDay),
      DateFormat('yyyy-MM-dd').format(lastDay),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shipmentState = ref.watch(shipmentProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20.h,
            ),
            Row(
              children: [
                Text(
                  'Shipment Info',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Year Dropdown
                Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<int>(
                      value: selectedYear,
                      isExpanded: true,
                      underline: SizedBox(), // Remove default underline
                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      dropdownColor: Colors.white,
                      items: years.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(
                            year.toString(),
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value;
                        });
                        _fetchShipmentData();
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12),
                //   Month Dropdown
                Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: selectedMonth,
                      isExpanded: true,
                      underline: SizedBox(), // Remove default underline
                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      dropdownColor: Colors.white,
                      items: months.map((month) {
                        return DropdownMenuItem(
                          value: month,
                          child: Text(
                            month,
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMonth = value;
                        });
                        _fetchShipmentData();
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12),

              ],
            ),
            SizedBox(
              height: 10.h,
            ),

            Expanded(
              child: shipmentState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (shipments) {
                  if (shipments.isEmpty) {
                    return const Center(child: Text('No shipment data available'));
                  }
                  return Center(child: ListView.builder(
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
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16.h,),
                              // Month Header
                              Text(
                                shipment.monthYear ?? 'N/A',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                    fontSize: 20.h
                                ),
                              ),

                              // Pie Chart and Stats Side by Side
                              Row(
                                children: [
                                  // Pie Chart
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 380.h,
                                          child: _buildDeliveryPieChart(shipment),
                                        ),
                                        Text('Delivery Details Chart')
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16.h),

                                  // Stats
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildEnhancedInfoRow('Total Order', (shipment.delivered!+shipment.notDelivered!), Colors.orange),
                                        _buildEnhancedInfoRow('Delivered', shipment.delivered, Colors.green),
                                        _buildEnhancedInfoRow('Pending Deliveries', shipment.notDelivered, Colors.red),
                                        Divider(),
                                        Text('Delivery Details',style: TextStyle(fontSize: 24.h,fontWeight: FontWeight.bold),),
                                        SizedBox(height: 8.h,),
                                        _buildEnhancedInfoRow('Advance Delivered', shipment.beforeShiped, Colors.blue),
                                        _buildEnhancedInfoRow('On-time Delivered', shipment.timelyShiped, Colors.teal),
                                        _buildEnhancedInfoRow('1 Week Delay Delivered', shipment.oneWeekDelay, Colors.indigo),
                                        _buildEnhancedInfoRow('2 Week Delay Delivered', shipment.twoWeekDelay, Colors.amber),
                                        _buildEnhancedInfoRow('>2 Week Delay Delivered', shipment.moreTwoWeekDelay, Colors.purple),
                                        _buildEnhancedInfoRow(
                                          'Total - ',
                                          (shipment.beforeShiped ?? 0) +
                                              (shipment.timelyShiped ?? 0) +
                                              (shipment.oneWeekDelay ?? 0) +
                                              (shipment.twoWeekDelay ?? 0) +
                                              (shipment.moreTwoWeekDelay ?? 0),
                                          Colors.purple,
                                        )

                                      ],
                                    ),

                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                            ],
                          ),
                        ),
                      );
                    },
                  ),);
                },
              ),
            ),
          ],
        ),
      ),
    );

  }
  Widget _buildDeliveryPieChart(ShipmentInfoModel shipment) {
    final delivered = shipment.delivered ?? 0;
    final notDelivered = shipment.notDelivered ?? 0;

    // Only show timing breakdown if there are delivered items
    if (delivered == 0) {
      return PieChart(

        PieChartData(
          sections: [
            PieChartSectionData(
              value: notDelivered.toDouble(),
              color: Colors.red,
              title: '100% Pending',
              radius: 80.h,
            ),
          ],
        ),
      );
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 80.h,
        sections: [
          PieChartSectionData(
            value: (shipment.beforeShiped ?? 0).toDouble(),
            color: Colors.blue,
            titleStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
            title: '${((shipment.beforeShiped ?? 0) / delivered * 100).toStringAsFixed(1)}%',
            radius: 100.h,
          ),
          PieChartSectionData(
            value: (shipment.timelyShiped ?? 0).toDouble(),
            color: Colors.green,
            titleStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
            title: '${((shipment.timelyShiped ?? 0) / delivered * 100).toStringAsFixed(1)}%',
            radius: 100.h,
          ),
          PieChartSectionData(
            value: (shipment.oneWeekDelay ?? 0).toDouble(),
            color: Colors.indigo,

            titleStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
            title: '${((shipment.oneWeekDelay ?? 0) / delivered * 100).toStringAsFixed(1)}%',
            radius: 100.h,
          ),
          PieChartSectionData(
            value: (shipment.twoWeekDelay ?? 0).toDouble(),
            color: Colors.amber,
            titleStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
            title: '${((shipment.twoWeekDelay ?? 0) / delivered * 100).toStringAsFixed(1)}%',
            radius: 100.h,
          ),
          PieChartSectionData(
            value: (shipment.moreTwoWeekDelay ?? 0).toDouble(),
            color: Colors.purple,
            titleStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
            title: '${((shipment.moreTwoWeekDelay ?? 0) / delivered * 100).toStringAsFixed(1)}%',
            radius: 100.h,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedInfoRow(String label, num? value, Color color) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.h),
          Expanded(
            child: Text(
              label,
              style:  TextStyle(
                fontSize: 20.h,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value?.toString() ?? '0',
            style:  TextStyle(
              fontSize: 18.h,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer()
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
    super.dispose();
  }
}

