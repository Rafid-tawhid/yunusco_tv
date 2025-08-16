import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:yunusco_ppt_tv/services/constants.dart';
import '../providers/attendance_provider.dart';
import '../services/helper_class.dart';

class DepartmentAttendanceSlider extends ConsumerStatefulWidget {
  const DepartmentAttendanceSlider({super.key});

  @override
  ConsumerState<DepartmentAttendanceSlider> createState() => _DepartmentAttendanceSliderState();
}

class _DepartmentAttendanceSliderState extends ConsumerState<DepartmentAttendanceSlider> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  final FocusNode _focusNode = FocusNode();
  bool _isAutoPlaying = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_pageController.hasClients && _isAutoPlaying) {
        _goToNextPage();
      }
    });
  }

  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlaying = !_isAutoPlaying;
    });
    if (_isAutoPlaying && !_timer!.isActive) {
      _startAutoScroll();
    }
  }

  void _goToNextPage() {
    final totalPages = ref.read(departmentAttendanceProvider).value?.sections.length ?? 1;
    final nextPage = (_currentPage + 1) % totalPages;
    _animateToPage(nextPage);
  }

  void _goToPreviousPage() {
    final totalPages = ref.read(departmentAttendanceProvider).value?.sections.length ?? 1;
    final prevPage = (_currentPage - 1) % totalPages;
    _animateToPage(prevPage >= 0 ? prevPage : totalPages - 1);
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(page, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    setState(() => _currentPage = page);
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _goToNextPage();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _goToPreviousPage();
      } else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.space) {
        _toggleAutoPlay();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(departmentAttendanceProvider);

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(
                _selectedDate != null
                    ? 'Strength on ${DateFormat('MMMM d, yyyy').format(_selectedDate!)}'
                    : 'Today : ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          elevation: 0,
          backgroundColor: myColors.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              onPressed: _pickDate,
              icon: Icon(Icons.calendar_month),
            ),
            SizedBox(width: 10,),
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedDate = null; // Clear date filter
                });
                debugPrint('_selectedDate $_selectedDate');
                // ref.invalidate(filteredReportListProvider);
                HelperClass.showMessage(message: 'Showing all dates', size: 20);
              },
              icon: const Icon(Icons.clear, size: 28),
              tooltip: 'Clear Date Filter',
            ),
            IconButton(
              onPressed: () {
                ref.invalidate(departmentAttendanceProvider);
                HelperClass.showMessage(message: 'Manually refreshed', size: 20);
              },
              icon: const Icon(Icons.refresh, size: 24),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Container(
          color: Colors.white,
          child: attendanceAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
            ),
            data: (data) {
              final sectionList = data.sections.entries.toList();

              return Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: sectionList.length,
                      onPageChanged: (index) => setState(() => _currentPage = index),
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
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                                decoration: BoxDecoration(
                                  color: myColors.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.blue.shade200, blurRadius: 8, offset: const Offset(0, 4))],
                                ),
                                child: Column(
                                  children: [Text(sectionName, style: TextStyle(fontSize: 20, color: Colors.blue.shade100))],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Stats Cards
                              Row(
                                children: [
                                  Expanded(child: _buildStatCard('Total Strength', '$totalStrength', Colors.blue.shade700, Icons.people_alt)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildStatCard('Present', '$totalPresent (${presentPercentage.toStringAsFixed(1)}%)', Colors.green.shade600, Icons.check_circle)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildStatCard('Absent', '$totalAbsent (${absentPercentage.toStringAsFixed(1)}%)', Colors.orange.shade600, Icons.warning)),
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
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            children: [
                                              const Text('Attendance Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              const SizedBox(height: 8),
                                              Expanded(
                                                child: PieChart(
                                                  dataMap: {"Present": totalPresent.toDouble(), "Absent": totalAbsent.toDouble()},
                                                  colorList: const [Colors.green, Colors.orange],
                                                  animationDuration: const Duration(milliseconds: 800),
                                                  chartRadius: MediaQuery.of(context).size.width / 4,
                                                  chartType: ChartType.ring,
                                                  ringStrokeWidth: 24,
                                                  legendOptions: const LegendOptions(showLegends: true, legendTextStyle: TextStyle(fontWeight: FontWeight.bold)),
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
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text('Employee Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              ),
                                              Expanded(
                                                child: ListView.separated(
                                                  itemCount: employees.length,
                                                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade300),
                                                  itemBuilder: (context, empIndex) {
                                                    final emp = employees[empIndex];
                                                    final empAbsentPercent = (emp.absent / emp.strength * 100);
                                                    return ListTile(
                                                      leading: CircleAvatar(
                                                        backgroundColor: empAbsentPercent > 20 ? Colors.orange.shade100 : Colors.green.shade100,
                                                        child: Icon(empAbsentPercent > 20 ? Icons.warning : Icons.check, color: empAbsentPercent > 20 ? Colors.orange : Colors.green),
                                                      ),
                                                      title: Text(emp.designation, style: const TextStyle(fontWeight: FontWeight.w500)),
                                                      subtitle: Text('${emp.present} present • ${emp.absent} absent'),
                                                      trailing: Chip(
                                                        label: Text(
                                                          '${empAbsentPercent.toStringAsFixed(1)}%',
                                                          style: TextStyle(color: empAbsentPercent > 20 ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                                                        ),
                                                        backgroundColor: empAbsentPercent > 20 ? Colors.red.shade50 : Colors.green.shade50,
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
                    ),
                  ),

                  // Navigation Controls
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        // Play/Pause Button
                        IconButton(icon: Icon(_isAutoPlaying ? Icons.pause : Icons.play_arrow, size: 32), color: myColors.primaryColor, onPressed: _toggleAutoPlay),
                        const SizedBox(height: 8),

                        // Navigation Arrows and Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Previous Button
                            IconButton(icon: const Icon(Icons.arrow_back, size: 32), color: myColors.primaryColor, onPressed: _goToPreviousPage),

                            // Page Indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List<Widget>.generate(
                                sectionList.length,
                                (index) => Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: _currentPage == index ? myColors.primaryColor : Colors.grey.shade300),
                                ),
                              ),
                            ),

                            // Next Button
                            IconButton(icon: const Icon(Icons.arrow_forward, size: 32), color: myColors.primaryColor, onPressed: _goToNextPage),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      // Update the state and provider correctly
      ref.read(selectedDateProvider2.notifier).state = formattedDate;

      debugPrint('Selected Date: $formattedDate');
      HelperClass.showMessage(message: 'Loading data for ${DateFormat('yyyy-MM-dd').format(pickedDate)}', size: 20);
    }
  }
}
