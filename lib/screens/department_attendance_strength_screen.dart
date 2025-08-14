import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:yunusco_ppt_tv/services/constants.dart';
import '../providers/attendance_provider.dart';

class DepartmentAttendanceSlider extends ConsumerStatefulWidget {
  const DepartmentAttendanceSlider({super.key});

  @override
  ConsumerState<DepartmentAttendanceSlider> createState() => _DepartmentAttendanceSliderState();
}

class _DepartmentAttendanceSliderState extends ConsumerState<DepartmentAttendanceSlider> {
  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_pageController.page!.toInt() + 1) %
            (ref.read(departmentAttendanceProvider).value?.sections.length ?? 1);
                _pageController.animateToPage(
                nextPage,
                duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
      );
    }
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(departmentAttendanceProvider);

    return Scaffold(

      appBar: AppBar(
        title: const Text('Production',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: myColors.primaryColor,
        iconTheme: IconThemeData(
          color: Colors.white
        )
      ),
      body: Container(
        color: Colors.white,
        child: attendanceAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
          data: (data) {
            final sectionList = data.sections.entries.toList();

            return PageView.builder(
              controller: _pageController,
              itemCount: sectionList.length,
              itemBuilder: (context, index) {
                final sectionName = sectionList[index].key;
                final employees = sectionList[index].value.employees;

                final int totalPresent = employees.fold(0, (sum, e) => sum + e.present);
                final int totalAbsent = employees.fold(0, (sum, e) => sum + e.absent);
                final int totalStrength = employees.fold(0, (sum, e) => sum + e.strength);
                final double presentPercentage = (totalPresent / totalStrength * 100);
                final double absentPercentage = (totalAbsent / totalStrength * 100);
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 8),
                        decoration: BoxDecoration(
                          color: myColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              sectionName,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.blue.shade100,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Strength',
                              '$totalStrength',
                              Colors.blue.shade700,
                              Icons.people_alt,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Present',
                              '$totalPresent (${presentPercentage.toStringAsFixed(1)}%)',
                              Colors.green.shade600,
                              Icons.check_circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Absent',
                              '$totalAbsent (${absentPercentage.toStringAsFixed(1)}%)',
                              Colors.orange.shade600,
                              Icons.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Chart and List
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pie Chart
                            Expanded(
                              flex: 2,
                              child: Card(
                                elevation: 4,

                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Attendance Overview',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: PieChart(
                                          dataMap: {
                                            "Present": totalPresent.toDouble(),
                                            "Absent": totalAbsent.toDouble(),
                                          },
                                          colorList: const [
                                            Colors.green,
                                            Colors.orange,
                                          ],
                                          animationDuration: const Duration(milliseconds: 800),
                                          chartRadius: MediaQuery.of(context).size.width / 4,
                                          chartType: ChartType.ring,
                                          ringStrokeWidth: 24,
                                          legendOptions: const LegendOptions(
                                            showLegends: true,
                                            legendTextStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          chartValuesOptions: const ChartValuesOptions(
                                            showChartValues: true,
                                            showChartValuesOutside: true,
                                            showChartValuesInPercentage: true,
                                            decimalPlaces: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Employee List
                            Expanded(
                              flex: 3,
                              child: Card(
                                elevation: 4,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Employee Details',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.separated(
                                          itemCount: employees.length,
                                          separatorBuilder: (_, __) => Divider(
                                            height: 1,
                                            color: Colors.grey.shade300,
                                          ),
                                          itemBuilder: (context, empIndex) {
                                            final emp = employees[empIndex];
                                            final empAbsentPercent = (emp.absent / emp.strength * 100);
                                            return ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: empAbsentPercent > 20
                                                    ? Colors.orange.shade100
                                                    : Colors.green.shade100,
                                                child: Icon(
                                                  empAbsentPercent > 20
                                                      ? Icons.warning
                                                      : Icons.check,
                                                  color: empAbsentPercent > 20
                                                      ? Colors.orange
                                                      : Colors.green,
                                                ),
                                              ),
                                              title: Text(
                                                emp.designation,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              subtitle: Text(
                                                '${emp.present} present • ${emp.absent} absent',
                                              ),
                                              trailing: Chip(
                                                label: Text(
                                                  '${empAbsentPercent.toStringAsFixed(1)}%',
                                                  style: TextStyle(
                                                    color: empAbsentPercent > 20
                                                        ? Colors.red
                                                        : Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                backgroundColor: empAbsentPercent > 20
                                                    ? Colors.red.shade50
                                                    : Colors.green.shade50,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}