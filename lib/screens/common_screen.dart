import 'package:countup/countup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_ppt_tv/models/employee_attendance_model.dart';
import '../providers/report_provider.dart';
import '../services/constants.dart';
import '../widgets/attendance_slide.dart';
import '../widgets/production_summary.dart';

class SlideDashboardScreen extends ConsumerStatefulWidget {
  const SlideDashboardScreen({super.key});

  @override
  ConsumerState<SlideDashboardScreen> createState() => _SlideDashboardScreenState();
}

class _SlideDashboardScreenState extends ConsumerState<SlideDashboardScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;
  bool _isPlaying = true;
  final FocusNode _focusNode = FocusNode();

  // final List<Map<String, dynamic>> slides = [
  //   {'title': 'Production Summary', 'color': Colors.blue},
  //   {'title': 'Department Attendance', 'color': Colors.green},
  //   {'title': 'Input Issues', 'color': Colors.purple},
  //   {'title': 'MMR', 'color': Colors.red},
  // ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(_handleAnimationUpdate);
    _startAutoPlay();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Request focus when the widget is first built
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _handleAnimationUpdate() {
    if (_animationController.status == AnimationStatus.completed) {
      _goToNextPage();
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _startAutoPlay() {
    if (_isPlaying) {
      _animationController.forward();
    }
  }

  void _stopAutoPlay() {
    _animationController.stop();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startAutoPlay();
      } else {
        _stopAutoPlay();
      }
    });
  }

  void _goToNextPage() {
    if (_currentPage < slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.animateToPage(
        slides.length - 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref.read(selectedDateProvider.notifier).state =
          picked.toIso8601String().split('T').first;
      ref.refresh(filteredReportListProvider);
      ref.refresh(departmentAttendanceProvider);
      ref.refresh(inputIssuesProvider);
      ref.refresh(mmrProvider);
    }
  }

  // Handle TV remote key events
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowRight:
          _goToNextPage();
          break;
        case LogicalKeyboardKey.arrowLeft:
          _goToPreviousPage();
          break;
        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.enter:
          _togglePlayPause();
          break;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);

    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Header with date picker and controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                        tooltip: 'Select date',
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedDate,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(_isPlaying ? 'Pause' : 'Play'),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: _togglePlayPause,
                        tooltip: _isPlaying ? 'Pause' : 'Play',
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_currentPage + 1}/${slides.length}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Main content area
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                    _animationController.reset();
                    if (_isPlaying) {
                      _animationController.forward();
                    }
                  });
                },
                children: [
                  buildProductionSummarySlide(ref),
                  buildDepartmentAttendanceSlide(ref),
                  _buildInputIssuesSlide(ref),
                  _buildMMRSlide(ref),
                ],
              ),
            ),
            // Slide indicators and navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  // Previous Button
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey.shade200),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 32),
                      color: myColors.primaryColor,
                      onPressed: _goToPreviousPage,
                    ),
                  ),
                  // Page Indicator
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(slides.length, (index) {
                        return Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? slides[index]['color']
                                : Colors.grey[300],
                          ),
                        );
                      }),
                    ),
                  ),
                  // Next Button
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey.shade200),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward, size: 32),
                      color: myColors.primaryColor,
                      onPressed: _goToNextPage,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== Slide Builders ========== //

  // Widget _buildProductionSummarySlide(WidgetRef ref) {
  //   final reportsAsync = ref.watch(filteredReportListProvider);
  //
  //   return reportsAsync.when(
  //     loading: () => const Center(child: CircularProgressIndicator()),
  //     error: (error, stack) => Center(child: Text('Error: $error')),
  //     data: (reports) {
  //       if (reports.isEmpty) {
  //         return const Center(child: Text('No production data available'));
  //       }
  //
  //       final totalQuantity = reports.fold(
  //           0, (sum, item) => sum + (item.quantity!.toInt() ?? 0));
  //       final avgEfficiency = reports.isEmpty
  //           ? 0
  //           : reports.fold(
  //           0, (sum, item) => sum + (item.averageEfficiency!.toInt() ?? 0)) /
  //           reports.length;
  //
  //       return Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Column(
  //             children: [
  //               Text(
  //                 'Production Summary',
  //                 style: TextStyle(
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.bold,
  //                   color: slides[0]['color'],
  //                 ),
  //               ),
  //               const SizedBox(height: 20),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   _buildSummaryCard(
  //                     title: 'Total Quantity',
  //                     value: totalQuantity.toString(),
  //                     color: slides[0]['color'],
  //                   ),
  //                   const SizedBox(width: 20),
  //                   _buildSummaryCard(
  //                     title: 'Avg Efficiency',
  //                     value: '${avgEfficiency.toStringAsFixed(1)}',
  //                     color: slides[0]['color'],
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //           Expanded(child: _buildProductionReportsSlide(ref))
  //         ],
  //       );
  //     },
  //   );
  // }


  Widget _buildProductionReportsSlide(WidgetRef ref) {
    final reportsAsync = ref.watch(filteredReportListProvider);

    return reportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (reports) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Production Reports',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: slides[2]['color'],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Item')),
                      DataColumn(label: Text('Line')),
                      DataColumn(label: Text('Qty')),
                      DataColumn(label: Text('Efficiency')),
                    ],
                    rows: reports.map((report) {
                      return DataRow(
                        cells: [
                          DataCell(Text(report.itemName ?? 'Unknown')),
                          DataCell(Text(report.totalLine?.toString() ?? 'N/A')),
                          DataCell(Text(report.quantity?.toString() ?? '0')),
                          DataCell(Text(
                            '${report.averageEfficiency?.toStringAsFixed(1) ?? '0'}%',
                            style: TextStyle(
                              color: (report.averageEfficiency ?? 0) > 80
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }




  Widget _buildInputIssuesSlide(WidgetRef ref) {
    final issuesAsync = ref.watch(inputIssuesProvider);

    return issuesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (issues) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Input Issues',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: slides[3]['color'],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Issue')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Line')),
                    ],
                    rows: issues.map((issue) {
                      return DataRow(
                        cells: [
                          DataCell(Text(issue.inputRelatedIssueName ?? 'Unknown')),
                          DataCell(Text(
                              issue.inputRelatedIssueTypeId?.toString() ?? 'N/A')),
                          DataCell(Text(issue.lineName ?? 'N/A')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMMRSlide(WidgetRef ref) {
    final mmrAsync = ref.watch(mmrProvider);

    return mmrAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (mmr) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Man Machine Ratio',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: slides[3]['color'],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getMMRColor(mmr),
                    width: 10,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${mmr.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _getMMRColor(mmr),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _getMMRStatus(mmr),
                style: TextStyle(
                  fontSize: 20,
                  color: _getMMRColor(mmr),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Color _getMMRColor(num mmr) {
    if (mmr > 90) return Colors.green;
    if (mmr > 75) return Colors.blue;
    if (mmr > 50) return Colors.orange;
    return Colors.red;
  }

  String _getMMRStatus(num mmr) {
    if (mmr > 90) return 'Excellent Condition';
    if (mmr > 75) return 'Good Condition';
    if (mmr > 50) return 'Needs Attention';
    return 'Critical Condition';
  }


}