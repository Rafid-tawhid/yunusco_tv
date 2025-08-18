import 'package:countup/countup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_ppt_tv/models/employee_attendance_model.dart';
import 'package:yunusco_ppt_tv/screens/shipment_slide_Screen.dart';
import 'package:yunusco_ppt_tv/services/helper_class.dart';
import '../providers/report_provider.dart';
import '../services/constants.dart';
import '../widgets/attendance_slide.dart';
import '../widgets/input_issues_slide.dart';
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
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
    HelperClass.showMessage(message: _isPlaying?'Play':'Pause');
  }
  //
  //

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
      ref.read(selectedDateProvider.notifier).state = picked.toIso8601String().split('T').first;
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
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
                color: myColors.primaryColor,
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
                  IconButton(onPressed: (){
                    Navigator.pop(context);
                  }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
                  InkWell(
                    onTap: (){
                      _selectDate(context);
                    },
                    child: Row(
                      children: [
                       Icon(Icons.calendar_today,color: Colors.white,),
                        const SizedBox(width: 8),
                        Text(
                          selectedDate,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: _togglePlayPause,
                    child: Row(
                      children: [
                        Text(_isPlaying ? 'Pause' : 'Play',style: TextStyle(color: Colors.white,),),
                        const SizedBox(width: 8),
                        Icon(_isPlaying ? Icons.pause : Icons.play_arrow,color: Colors.white,),
                        const SizedBox(width: 8),
                        Text(
                          '${_currentPage + 1}/${slides.length}',
                          style: const TextStyle(fontSize: 16,color: Colors.white,),
                        ),
                      ],
                    ),
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
                  buildInputIssuesSlide(ref),
                  ShipmentInfoScreen(),
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
                'Man Vs Machine Ratio(MMR)',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getMMRColor(mmr/100),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getMMRColor(mmr/100),
                    width: 10,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${(mmr/100).toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _getMMRColor(mmr/100),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _getMMRStatus(mmr/100),
                style: TextStyle(
                  fontSize: 20,
                  color: _getMMRColor(mmr/100),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Color _getMMRColor(num mmr) {
    if (mmr > 0 && mmr<2) return Colors.green;
    // if (mmr > 75) return 'Good Condition';
    // if (mmr > 50) return 'Needs Attention';
    return Colors.red;
  }

  String _getMMRStatus(num mmr) {
    if (mmr > 0 && mmr<2) return 'Good Condition';
    // if (mmr > 75) return 'Good Condition';
    // if (mmr > 50) return 'Needs Attention';
    return 'Critical Condition';
  }


}