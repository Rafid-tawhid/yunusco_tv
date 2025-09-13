// screens/dhu_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dhu_model.dart';
import '../providers/report_provider.dart';

class DHUDashboard extends ConsumerStatefulWidget {
  const DHUDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<DHUDashboard> createState() => _DHUDashboardState();
}

class _DHUDashboardState extends ConsumerState<DHUDashboard> {
  String selectedDate = '2025-08-16'; // Default date

  @override
  Widget build(BuildContext context) {
    final dhuAsync = ref.watch(dhuProvider(selectedDate));

    return dhuAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildError(error, () => ref.refresh(dhuProvider(selectedDate))),
      data: (dhuResponse) {
        if (!dhuResponse.success) {
          return Center(
            child: Text(
              dhuResponse.message,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          );
        }

        return _buildDashboard(dhuResponse.data);
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
      ref.refresh(dhuProvider(selectedDate));
    }
  }

  Widget _buildDashboard(DHUData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date selector
        SizedBox(height: 12,),
        // Total DHU
        _buildTotalDHU(data.totalDHU),

        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(width: 10,),
            Expanded(child: _buildSectionTable(data.sectionWiseDHU),),
            SizedBox(width: 20,),
            Expanded(child: _buildLineTable(data.lineWiseDHU),),
            SizedBox(width: 10,),
          ],
        ),

      ],
    );
  }

  Widget _buildTotalDHU(TotalDHU totalDHU) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Total DHU: ',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            '${totalDHU.totalDHU.toStringAsFixed(2)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _getDHUColor(totalDHU.totalDHU),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTable(List<SectionWiseDHU> sections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section-wise DHU Table
        const Text(
          'Section-wise DHU',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8,),
        Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Colors.grey),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Section', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('DHU (%)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...sections.map((section) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(section.sectionName),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    section.sectionDHU.toStringAsFixed(2),
                    style: TextStyle(color: _getDHUColor(section.sectionDHU)),
                  ),
                ),
              ],
            )).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildLineTable(List<LineWiseDHU> lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Line-wise DHU',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8,),
        Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Colors.grey),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Line', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('DHU (%)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...lines.map((line) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(line.lineName),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    line.lineDHU.toStringAsFixed(2),
                    style: TextStyle(color: _getDHUColor(line.lineDHU)),
                  ),
                ),
              ],
            )).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildError(Object error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: ${error.toString()}',
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Color _getDHUColor(double dhuValue) {
    if (dhuValue <= 1.0) return Colors.green;
    if (dhuValue <= 5.0) return Colors.orange;
    return Colors.red;
  }
}