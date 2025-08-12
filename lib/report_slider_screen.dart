import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yunusco_ppt_tv/providers/report_provider.dart';
import 'package:yunusco_ppt_tv/services/helper_class.dart';
import 'models/factory_report_model.dart';

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
      ref.invalidate(reportListProvider); // Forces re-fetch from API
      HelperClass.showMessage(message: 'Data refreshed', size: 20);
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
    final asyncValue = ref.watch(reportListProvider);
    return asyncValue.maybeWhen(
      data: (data) => data,
      orElse: () => [],
    );
  }

  Widget _buildReportCard(FactoryReportModel report) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
                  children: [
                    const Icon(Icons.factory, size: 56, color: Colors.blueAccent),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            report.itemName ?? "Item Name",
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                          Image.asset('assets/icon/icon.png',height: 80,width: 80,)
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Metrics Section
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 132,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
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




  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportListProvider);

    return RawKeyboardListener(
      focusNode: _mainFocusNode,
      onKey: _handleKeyEvent,
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        ref.invalidate(reportListProvider);
                        HelperClass.showMessage(message: 'Manually refreshed', size: 20);
                      },
                      icon: const Icon(Icons.refresh, size: 24),
                      tooltip: 'Refresh',
                    ),
                  ),

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
