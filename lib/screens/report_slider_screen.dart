import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:yunusco_ppt_tv/providers/report_provider.dart';
import 'package:yunusco_ppt_tv/services/constants.dart';
import 'package:yunusco_ppt_tv/services/helper_class.dart';
import '../models/factory_report_model.dart';




class FactoryReportSlider extends ConsumerStatefulWidget {
  const FactoryReportSlider({Key? key}) : super(key: key);

  @override
  ConsumerState<FactoryReportSlider> createState() => _FactoryReportSliderState();
}

class _FactoryReportSliderState extends ConsumerState<FactoryReportSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  bool _isPaused = false;
  final FocusNode _mainFocusNode = FocusNode();
  Timer? _refreshTimer;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _startAutoRefresh();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_mainFocusNode);
    });
  }
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      ref.invalidate(reportRepositoryProvider);
      HelperClass.showMessage(
        message: _selectedDate != null
            ? 'Data refreshed for ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'
            : 'Data refreshed',
        size: 20,
      );
    });
  }


  @override
  void dispose() {
    _timer?.cancel();
    _refreshTimer?.cancel(); // 🔁 Cancel refresh timer
    _pageController.dispose();
    _mainFocusNode.dispose();
    super.dispose();
  }


  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_isPaused) _goToNextPage();
    });
  }

  void _goToNextPage() {
    final reports = _getReports();
    if (reports.isEmpty) return;

    setState(() {
      _currentPage = (_currentPage + 1) % reports.length;
    });
    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    HapticFeedback.selectionClick();
  }

  void _goToPreviousPage() {
    final reports = _getReports();
    if (reports.isEmpty) return;

    setState(() {
      _currentPage = (_currentPage - 1 + reports.length) % reports.length;
    });
    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    HapticFeedback.selectionClick();
  }

  void _togglePause() {
    if(_isPaused){
      HelperClass.showMessage(message: 'Play',size: 20);
    }
    else {
      HelperClass.showMessage(message: 'Pause',size: 20);
    }
    setState(() {
      _isPaused = !_isPaused;
    });
    HapticFeedback.selectionClick();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _goToNextPage();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _goToPreviousPage();
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select) {
        _togglePause();
      }
    }
  }

  List<FactoryReportModel> _getReports() {
    // Use reportListProvider instead of reportRepositoryProvider
    final asyncValue = ref.watch(filteredReportListProvider);
    return asyncValue.maybeWhen(
      data: (data) => data,
      orElse: () => [],
    );
  }

  Widget _buildReportCard(FactoryReportModel report) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            //  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.factory, size: 36, color: myColors.primaryColor),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            report.itemName ?? "Item Name",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                          Image.asset('assets/icon/icon.png',height: 48,width: 48,)
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Metrics Section
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 90, // reduced from 132
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  children: [
                    _buildMetricBox(Icons.view_module, "Total Lines", report.totalLine.toString()),
                    _buildMetricBox(Icons.speed, "Avg. Efficiency", "${report.averageEfficiency}%"),
                    _buildMetricBox(Icons.inventory, "Quantity", report.quantity.toString()),
                    _buildMetricBox(Icons.date_range, "Prod. Date", report.productionDate ?? ""),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBox(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.blueGrey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 20, color: Colors.black87)),
                Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Add this new method for date picking
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      // Update the state and provider correctly
      ref.read(selectedDateProvider.notifier).state = formattedDate;

      debugPrint('Selected Date: $formattedDate');
      HelperClass.showMessage(
        message: 'Loading data for ${DateFormat('yyyy-MM-dd').format(pickedDate)}',
        size: 20,
      );
    }
  }



  // ... keep all your existing methods unchanged ...

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(filteredReportListProvider);

    return RawKeyboardListener(
      focusNode: _mainFocusNode,
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _pickDate(); // Add date picker trigger on up arrow
          } else {
            _handleKeyEvent(event); // Keep existing key handling
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: reportsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (reports) {
              if (reports.isEmpty) {
                return const Center(child: Text('No report data available'));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modified header row with date picker
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_selectedDate != null)
                          Text(
                            DateFormat('MMMM d, yyyy').format(_selectedDate!),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          )
                        else
                           Text(
                            'Today : ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today, size: 28),
                              tooltip: 'Select Date',
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDate = null; // Clear date filter
                                });
                                debugPrint('_selectedDate ${_selectedDate}');
                                // ref.invalidate(filteredReportListProvider);
                                HelperClass.showMessage(message: 'Showing all dates', size: 20);
                              },
                              icon: const Icon(Icons.clear, size: 28),
                              tooltip: 'Clear Date Filter',
                            ),
                            IconButton(
                              onPressed: () {
                                ref.invalidate(filteredReportListProvider);
                                HelperClass.showMessage(message: 'Manually refreshed', size: 20);
                              },
                              icon: const Icon(Icons.refresh, size: 24),
                              tooltip: 'Refresh',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Keep the rest of your existing build code exactly the same
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: reports.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        return _buildReportCard(reports[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      reports.length,
                          (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 12 : 8,
                        height: _currentPage == index ? 12 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.blueAccent
                              : Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 12,),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: IconButton(
                          onPressed: _goToPreviousPage,
                          icon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: const Icon(Icons.arrow_back,size: 24,color: Colors.black,),
                          ),
                          tooltip: 'Previous',
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          onPressed: _togglePause,
                          icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause,size: 48,color: Colors.grey,),
                          tooltip: _isPaused ? 'Resume' : 'Pause',
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: IconButton(
                          onPressed: _goToNextPage,
                          icon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: const Icon(Icons.arrow_forward,size: 24,),
                          ),
                          tooltip: 'Next',
                        ),
                      ),
                      SizedBox(width: 12,),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}