import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_ppt_tv/screens/user_dts.dart';

import '../providers/item_provider.dart';

//import 'package:countup/countup.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:yunusco_ppt_tv/models/employee_attendance_model.dart';
//
// import '../providers/report_provider.dart';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../services/constants.dart';
//
// class SlideDashboardScreen extends ConsumerStatefulWidget {
//   const SlideDashboardScreen({super.key});
//
//   @override
//   ConsumerState<SlideDashboardScreen> createState() => _SlideDashboardScreenState();
// }
//
// class _SlideDashboardScreenState extends ConsumerState<SlideDashboardScreen>
//     with SingleTickerProviderStateMixin {
//   final PageController _pageController = PageController();
//   late AnimationController _animationController;
//   int _currentPage = 0;
//   bool _isPlaying = true;
//
//   final List<Map<String, dynamic>> _slides = [
//     {'title': 'Production Summary', 'color': Colors.blue},
//     {'title': 'Department Attendance', 'color': Colors.green},
//     {'title': 'Production Reports', 'color': Colors.orange},
//     {'title': 'Input Issues', 'color': Colors.purple},
//     {'title': 'MMR', 'color': Colors.red},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 5),
//     )..addListener(_handleAnimationUpdate);
//     _startAutoPlay();
//   }
//
//   void _handleAnimationUpdate() {
//     if (_animationController.status == AnimationStatus.completed) {
//       _goToNextPage();
//       _animationController.reset();
//       _animationController.forward();
//     }
//   }
//
//   void _startAutoPlay() {
//     if (_isPlaying) {
//       _animationController.forward();
//     }
//   }
//
//   void _stopAutoPlay() {
//     _animationController.stop();
//   }
//
//   void _togglePlayPause() {
//     setState(() {
//       _isPlaying = !_isPlaying;
//       if (_isPlaying) {
//         _startAutoPlay();
//       } else {
//         _stopAutoPlay();
//       }
//     });
//   }
//
//   void _goToNextPage() {
//     if (_currentPage < _slides.length - 1) {
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     } else {
//       _pageController.animateToPage(
//         0,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
//
//   void _goToPreviousPage() {
//     if (_currentPage > 0) {
//       _pageController.previousPage(
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     } else {
//       _pageController.animateToPage(
//         _slides.length - 1,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       ref.read(selectedDateProvider.notifier).state =
//           picked.toIso8601String().split('T').first;
//       // Refresh all data when date changes
//       ref.refresh(filteredReportListProvider);
//       ref.refresh(departmentAttendanceProvider);
//       ref.refresh(inputIssuesProvider);
//       ref.refresh(mmrProvider);
//     }
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final selectedDate = ref.watch(selectedDateProvider);
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // Header with date picker and controls
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 4,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.calendar_today),
//                       onPressed: () => _selectDate(context),
//                       tooltip: 'Select date',
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       selectedDate,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Text(_isPlaying ? 'Pause' : 'Play'),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//                       onPressed: _togglePlayPause,
//                       tooltip: _isPlaying ? 'Pause' : 'Play',
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       '${_currentPage + 1}/${_slides.length}',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           // Progress indicator
//           // LinearProgressIndicator(
//           //   value: _isPlaying ? _animationController.value : null,
//           //   backgroundColor: Colors.grey[200],
//           //   valueColor: AlwaysStoppedAnimation<Color>(
//           //     _slides[_currentPage]['color'],
//           //   ),
//           // ),
//           // Main content area
//           Expanded(
//             child: PageView(
//               controller: _pageController,
//               onPageChanged: (index) {
//                 setState(() {
//                   _currentPage = index;
//                   _animationController.reset();
//                   if (_isPlaying) {
//                     _animationController.forward();
//                   }
//                 });
//               },
//               children: [
//                 _buildProductionSummarySlide(ref),
//                 _buildDepartmentAttendanceSlide(ref),
//                 _buildProductionReportsSlide(ref),
//                 _buildInputIssuesSlide(ref),
//                 _buildMMRSlide(ref),
//               ],
//             ),
//           ),
//           // Slide indicators
//
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 12.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(width: 10),
//                 // Previous Button
//                 Container(
//                   decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
//                   child: IconButton(icon: const Icon(Icons.arrow_back, size: 32), color: myColors.primaryColor, onPressed: _goToPreviousPage),
//                 ),
//
//                 // Page Indicator
//                 Expanded(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(_slides.length, (index) {
//                       return Container(
//                         width: 12,
//                         height: 12,
//                         margin: const EdgeInsets.symmetric(horizontal: 4),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: _currentPage == index
//                               ? _slides[index]['color']
//                               : Colors.grey[300],
//                         ),
//                       );
//                     }),
//                   ),
//                 ),
//
//                 // Next Button
//                 Container(
//                   decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
//                   child: IconButton(icon: const Icon(Icons.arrow_forward, size: 32), color: myColors.primaryColor, onPressed: _goToNextPage),
//                 ),
//
//                 SizedBox(width: 10),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ========== Slide Builders ========== //
//
//   Widget _buildProductionSummarySlide(WidgetRef ref) {
//     final reportsAsync = ref.watch(filteredReportListProvider);
//
//     return reportsAsync.when(
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (error, stack) => Center(child: Text('Error: $error')),
//       data: (reports) {
//         if (reports.isEmpty) {
//           return const Center(child: Text('No production data available'));
//         }
//
//         final totalQuantity = reports.fold(0, (sum, item) => sum + (item.quantity!.toInt() ?? 0));
//         final avgEfficiency = reports.isEmpty
//             ? 0
//             : reports.fold(0, (sum, item) => sum + (item.averageEfficiency!.toInt() ?? 0)) / reports.length;
//
//         return Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Production Summary',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: _slides[0]['color'],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildSummaryCard(
//                       title: 'Total Quantity',
//                       value: totalQuantity.toString(),
//                       color: _slides[0]['color'],
//                     ),
//                     const SizedBox(width: 20),
//                     _buildSummaryCard(
//                       title: 'Avg Efficiency',
//                       value: '$avgEfficiency',
//                       color: _slides[0]['color'],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildDepartmentAttendanceSlide(WidgetRef ref) {
//     final attendanceAsync = ref.watch(departmentAttendanceProvider);
//
//     return attendanceAsync.when(
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (error, stack) => Center(child: Text('Error: $error')),
//       data: (departmentData) {
//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               Text(
//                 'Department Attendance',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: _slides[1]['color'],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Card(
//                 elevation: 3,
//                 color: Colors.white,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       Text(
//                         departmentData.departmentName,
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ...departmentData.sections.values.map((section) {
//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   section.sectionName,
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 Text(
//                                   getAbsentPresentRatio(section.employees),
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             ...section.employees.map((employee) => Padding(
//                               padding: const EdgeInsets.only(left: 16, bottom: 8),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     flex: 2,
//                                     child: Text(employee.designation),
//                                   ),
//                                   Expanded(
//                                     child: Text(
//                                       '${employee.present}/${employee.strength}',
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Text(
//                                       '${employee.absentPercent.toStringAsFixed(1)}% absent',
//                                       style: TextStyle(
//                                         color: employee.absentPercent > 10
//                                             ? Colors.red
//                                             : Colors.green,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )),
//                             const Divider(),
//                           ],
//                         );
//                       }),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildProductionReportsSlide(WidgetRef ref) {
//     final reportsAsync = ref.watch(filteredReportListProvider);
//
//     return reportsAsync.when(
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (error, stack) => Center(child: Text('Error: $error')),
//       data: (reports) {
//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               Text(
//                 'Production Reports',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: _slides[2]['color'],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Card(
//                 elevation: 3,
//                 color: Colors.white,
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: DataTable(
//                     columns: const [
//                       DataColumn(label: Text('Item')),
//                       DataColumn(label: Text('Line')),
//                       DataColumn(label: Text('Qty')),
//                       DataColumn(label: Text('Efficiency')),
//                     ],
//                     rows: reports.map((report) {
//                       return DataRow(
//                         cells: [
//                           DataCell(Text(report.itemName ?? 'Unknown')),
//                           DataCell(Text(report.totalLine?.toString() ?? 'N/A')),
//                           DataCell(Text(report.quantity?.toString() ?? '0')),
//                           DataCell(Text(
//                             '${report.averageEfficiency?.toStringAsFixed(1) ?? '0'}%',
//                             style: TextStyle(
//                               color: (report.averageEfficiency ?? 0) > 80
//                                   ? Colors.green
//                                   : Colors.orange,
//                             ),
//                           )),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildInputIssuesSlide(WidgetRef ref) {
//     final issuesAsync = ref.watch(inputIssuesProvider);
//
//     return issuesAsync.when(
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (error, stack) => Center(child: Text('Error: $error')),
//       data: (issues) {
//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               Text(
//                 'Input Issues',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: _slides[3]['color'],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Card(
//                 elevation: 3,
//                 color: Colors.white,
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: DataTable(
//                     columns: const [
//                       DataColumn(label: Text('Issue')),
//                       DataColumn(label: Text('Type')),
//                       DataColumn(label: Text('Line')),
//                     ],
//                     rows: issues.map((issue) {
//                       return DataRow(
//                         cells: [
//                           DataCell(Text(issue.inputRelatedIssueName ?? 'Unknown')),
//                           DataCell(Text(
//                               issue.inputRelatedIssueTypeId?.toString() ?? 'N/A')),
//                           DataCell(Text(issue.lineName ?? 'N/A')),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildMMRSlide(WidgetRef ref) {
//     final mmrAsync = ref.watch(mmrProvider);
//
//     return mmrAsync.when(
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (error, stack) => Center(child: Text('Error: $error')),
//       data: (mmr) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Man Machine Ratio',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: _slides[4]['color'],
//                 ),
//               ),
//               const SizedBox(height: 30),
//               Container(
//                 width: 200,
//                 height: 200,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: _getMMRColor(mmr),
//                     width: 10,
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${mmr.toStringAsFixed(1)}%',
//                     style: TextStyle(
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                       color: _getMMRColor(mmr),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 _getMMRStatus(mmr),
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: _getMMRColor(mmr),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildSummaryCard({
//     required String title,
//     required String value,
//     required Color color,
//   }) {
//     return Card(
//       elevation: 1,
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Countup(
//               begin: 0,
//               end: double.parse(value.toString()),
//               duration: Duration(seconds: 2),
//               separator: ',',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Color _getMMRColor(num mmr) {
//     if (mmr > 90) return Colors.green;
//     if (mmr > 75) return Colors.blue;
//     if (mmr > 50) return Colors.orange;
//     return Colors.red;
//   }
//
//   String _getMMRStatus(num mmr) {
//     if (mmr > 90) return 'Excellent Condition';
//     if (mmr > 75) return 'Good Condition';
//     if (mmr > 50) return 'Needs Attention';
//     return 'Critical Condition';
//   }
//
//   String getAbsentPresentRatio(List<EmployeeAttendance> employees) {
//     int present=0;
//     int absent=0;
//     employees.forEach((e){
//       present= present+e.present;
//       absent= absent+e.absent;
//     });
//
//     return ' ($present/${present+absent})';
//   }
// }
