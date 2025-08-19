import 'package:countup/countup.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_ppt_tv/services/helper_class.dart';

import '../models/factory_report_model.dart';
import '../providers/report_provider.dart';
import '../services/constants.dart';

Widget buildProductionSummarySlide(WidgetRef ref) {
  final reportsAsync = ref.watch(filteredReportListProvider);


  return reportsAsync.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (error, stack) => Center(child: Text('Error: $error')),
    data: (reports) {
      if (reports.isEmpty) {
        return const Center(child: Text('No production data available'));
      }

      final totalQuantity = reports.fold(
          0, (sum, item) => sum + (item.quantity!.toInt() ?? 0));
      final avgEfficiency = reports.isEmpty
          ? 0
          : reports.fold(
          0, (sum, item) => sum + (item.averageEfficiency!.toInt() ?? 0)) /
          reports.length;
      final valMap = <String, double>{};
      for (final e in reports) {
        valMap[e.itemName ?? 'Unknown'] = e.averageEfficiency?.toDouble() ?? 0.0;
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 400,
                  width: 400,
                  child: BeautifulPieChart(
                    title: "Efficiency Distribution",
                    valueMap: valMap,
                    titleColor: Colors.blue, // Optional
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Production Summary',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: slides[0]['color'],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    _buildSummaryCard(
                      title: 'Total Quantity',
                      value: totalQuantity.toString(),
                      color: slides[0]['color'],
                    ),
                    const SizedBox(width: 20),
                    _buildSummaryCard(
                      title: 'Avg Efficiency',
                      value: avgEfficiency.toStringAsFixed(1),
                      color: slides[0]['color'],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _buildProductionReportsSlide(ref)),
        ],
      );
    },
  );
  
  
}
class BeautifulPieChart extends StatelessWidget {
  final String title;
  final Map<String, double> valueMap;
  final Color? titleColor;

  const BeautifulPieChart({
    super.key,
    required this.title,
    required this.valueMap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
    ];

    final data = valueMap.entries.map((entry) {
      final index = valueMap.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        title: '${entry.value.toStringAsFixed(1)}%',
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      elevation: 6,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor ?? Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: data,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: valueMap.keys.map((label) {
                  final index = valueMap.keys.toList().indexOf(label);
                  return _buildLegendItem(
                    colors[index % colors.length],
                    label,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
Widget _buildSummaryCard({
  required String title,
  required String value,
  required Color color,
}) {
  return Card(
    elevation: 1,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Countup(
            begin: 0,
            end: double.parse(value.toString()),
            suffix: title=='Avg Efficiency'?'%':'',
            duration: const Duration(seconds: 2),
            separator: ',',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildProductionReportsSlide(WidgetRef ref) {
  final reportsAsync = ref.watch(filteredReportListProvider);

  return reportsAsync.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (error, stack) => Center(child: Text('Error: $error')),
    data: (reports) {
      num totalLineSum = reports.fold(0, (sum, report) => sum + (report.totalLine ?? 0));
      num totalQty = reports.fold(0, (sum, report) => sum + (report.quantity ?? 0));

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Production Reports',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: slides[2]['color'],
              ),
            ),
          ),
          Expanded( // Take remaining space
            child: Card(
              elevation: 1,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical, // Primary vertical scroll
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Nested horizontal scroll
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                          minHeight: constraints.maxHeight,
                        ),
                        child: DataTable(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(
                              label: SizedBox(
                                width: 200,
                                child: Text('Item'),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Text('Line'),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Text('Qty'),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 120,
                                child: Text('Efficiency'),
                              ),
                            ),
                          ],
                          rows: [
                            ...reports.map((report) => DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 200,
                                    child: Text(report.itemName ?? 'Unknown'),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: Text(report.totalLine?.toString() ?? 'N/A'),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: Text(report.quantity?.toString() ?? '0'),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      '${report.averageEfficiency?.toStringAsFixed(1) ?? '0'}%',
                                      style: TextStyle(
                                        color: (report.averageEfficiency ?? 0) > 80
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Total Line',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      '$totalLineSum',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      '${totalQty} pcs',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(SizedBox(width: 100)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    },
  );
}

// Widget _buildProductionReportsSlide(WidgetRef ref) {
//   final reportsAsync = ref.watch(filteredReportListProvider);
//
//   return reportsAsync.when(
//     loading: () => const Center(child: CircularProgressIndicator()),
//     error: (error, stack) => Center(child: Text('Error: $error')),
//     data: (reports) {
//       return Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Text(
//               'Production Reports',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: slides[2]['color'],
//               ),
//             ),
//           ),
//           Expanded(
//             child: Container(
//               height: HelperClass.getScreenHeight()/2,
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Card(
//                 elevation: 1,
//                 child: LayoutBuilder(
//                   builder: (context, constraints) {
//                     num totalLineSum = reports.fold(0, (sum, report) => sum + (report.totalLine ?? 0));
//                     num totalQty = reports.fold(0, (sum, report) => sum + (report.quantity ?? 0));
//                     return SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: ConstrainedBox(
//                         constraints: BoxConstraints(
//                           minWidth: constraints.maxWidth,
//                         ),
//                         child: DataTable(
//                           decoration: const BoxDecoration(
//                             color: Colors.white,
//                           ),
//                           columnSpacing: 24, // Adjust spacing as needed
//                           columns: const [
//                             DataColumn(
//                               label: SizedBox(
//                                 width: 200, // Set your desired column width
//                                 child: Text('Item'),
//                               ),
//                             ),
//                             DataColumn(
//                               label: SizedBox(
//                                 width: 100,
//                                 child: Text('Line'),
//                               ),
//                             ),
//                             DataColumn(
//                               label: SizedBox(
//                                 width: 100,
//                                 child: Text('Qty'),
//                               ),
//                             ),
//                             DataColumn(
//                               label: SizedBox(
//                                 width: 120,
//                                 child: Text('Efficiency'),
//                               ),
//                             ),
//                           ],
//                           rows: [
//                             ...reports.map((report) {
//                             return DataRow(
//                               cells: [
//                                 DataCell(
//                                   SizedBox(
//                                     width: 200, // Match column width
//                                     child: Text(report.itemName ?? 'Unknown'),
//                                   ),
//                                 ),
//                                 DataCell(
//                                   SizedBox(
//                                     width: 100,
//                                     child: Text(report.totalLine?.toString() ?? 'N/A'),
//                                   ),
//                                 ),
//                                 DataCell(
//                                   SizedBox(
//                                     width: 100,
//                                     child: Text(report.quantity?.toString() ?? '0'),
//                                   ),
//                                 ),
//                                 DataCell(
//                                   SizedBox(
//                                     width: 120,
//                                     child: Text(
//                                       '${report.averageEfficiency?.toStringAsFixed(1) ?? '0'}%',
//                                       style: TextStyle(
//                                         color: (report.averageEfficiency ?? 0) > 80
//                                             ? Colors.green
//                                             : Colors.red,
//                                         fontWeight: FontWeight.bold
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           }),
//                             DataRow(
//                               cells: [
//                                 DataCell(
//                                   SizedBox(
//                                     width: 200, // Match column width
//                                     child: Text('Total Line ',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
//                                   ),
//                                 ),
//                                 DataCell(
//                                   SizedBox(
//                                     width: 100,
//                                     child: Text('$totalLineSum',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16)),
//                                   ),
//                                 ),
//                                 DataCell(
//                                   SizedBox(
//                                     width: 100,
//                                     child: Text('${totalQty} pcs',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 14)),
//                                   ),
//                                 ),
//                                 DataCell(
//                                   SizedBox(
//                                     width: 100,
//                                     child: Text(''),
//                                   ),
//                                 ),
//                               ],
//                             )
//
//
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }