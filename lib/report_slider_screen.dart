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

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_mainFocusNode);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  List<FactoryReport> _getReports() {
    final asyncValue = ref.watch(reportListProvider);
    return asyncValue.maybeWhen(
      data: (data) => data,
      orElse: () => [],
    );
  }

  Widget _buildReportCard(FactoryReport report) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: report.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(report.icon),
          ),
          const SizedBox(height: 20),
          Text(
            report.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            report.value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                report.change.startsWith('+')
                    ? Icons.arrow_upward
                    : report.change.startsWith('-')
                    ? Icons.arrow_downward
                    : Icons.remove,
                color: report.change.startsWith('+')
                    ? Colors.green
                    : report.change.startsWith('-')
                    ? Colors.red
                    : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 6),
              Text(
                report.change,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: report.change.startsWith('+')
                      ? Colors.green
                      : report.change.startsWith('-')
                      ? Colors.red
                      : Colors.grey,
                ),
              ),
            ],
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
                children: [
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
                      IconButton(
                        onPressed: _goToPreviousPage,
                        icon: const Icon(Icons.arrow_back,size: 24,),
                        tooltip: 'Previous',
                      ),
                      Expanded(
                        child: IconButton(
                          onPressed: _togglePause,
                          icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause,size: 48,),
                          tooltip: _isPaused ? 'Resume' : 'Pause',
                        ),
                      ),
                      IconButton(
                        onPressed: _goToNextPage,
                        icon: const Icon(Icons.arrow_forward,size: 24,),
                        tooltip: 'Next',
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
