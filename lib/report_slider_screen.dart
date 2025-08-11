import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focusable_control_builder/focusable_control_builder.dart';
import 'dart:async';

class FactoryReportSlider extends StatefulWidget {
  @override
  _FactoryReportSliderState createState() => _FactoryReportSliderState();
}

class _FactoryReportSliderState extends State<FactoryReportSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  final FocusNode _mainFocusNode = FocusNode();
  bool _isPaused = false;

  final List<Map<String, dynamic>> _reports = [
    {
      'title': 'Production Today',
      'value': '1,250 pcs',
      'change': '+5.2%',
      'icon': Icons.factory,
      'color': Colors.blue[400],
    },
    {
      'title': 'Efficiency',
      'value': '78.5%',
      'change': '+2.1%',
      'icon': Icons.trending_up,
      'color': Colors.green[400],
    },
    {
      'title': 'Defect Rate',
      'value': '2.4%',
      'change': '-0.8%',
      'icon': Icons.qr_code,
      'color': Colors.orange[400],
    },
    {
      'title': 'Line Utilization',
      'value': '85%',
      'change': '±0%',
      'icon': Icons.show_chart,
      'color': Colors.purple[400],
    },
    {
      'title': 'On-Time Delivery',
      'value': '92%',
      'change': '+3.5%',
      'icon': Icons.delivery_dining,
      'color': Colors.teal[400],
    },
  ];

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
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (!_isPaused) {
        _goToNextPage();
      }
    });
  }

  void _togglePause() {
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
      } else if (event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        _togglePause();
      }
    }
  }

  void _goToNextPage() {
    if (_currentPage < _reports.length - 1) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    HapticFeedback.selectionClick();
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _currentPage--;
    } else {
      _currentPage = _reports.length - 1;
    }
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    HapticFeedback.selectionClick();
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: report['color']!.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(report['icon'], color: report['color'], size: 40),
              ),
              SizedBox(height: 20),
              Text(
                report['title'],
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 15),
              Text(
                report['value'],
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    report['change'].startsWith('+')
                        ? Icons.arrow_upward
                        : report['change'].startsWith('-')
                        ? Icons.arrow_downward
                        : Icons.remove,
                    color: report['change'].startsWith('+')
                        ? Colors.green
                        : report['change'].startsWith('-')
                        ? Colors.red
                        : Colors.grey,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    report['change'],
                    style: TextStyle(
                      fontSize: 24,
                      color: report['change'].startsWith('+')
                          ? Colors.green
                          : report['change'].startsWith('-')
                          ? Colors.red
                          : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _mainFocusNode,
      onKey: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  //  height: MediaQuery.of(context).size.height * 0.6,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _reports.length,
                    onPageChanged: (int page) {
                      setState(() => _currentPage = page);
                    },
                    itemBuilder: (context, index) {
                      return _buildReportCard(_reports[index]);
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 10),
                    FocusableControlBuilder(
                      onPressed: _goToPreviousPage,
                      builder: (context, control) {
                        return Container(
                          width: 100,
                          height: 70,
                          decoration: BoxDecoration(
                            color: control.isFocused ? Colors.blue[800] : Colors.blue[200],
                            borderRadius: BorderRadius.circular(10),
                            border: control.isFocused
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 36,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_reports.length, (index) {
                              return Container(
                                width: _currentPage == index ? 30 : 15,
                                height: 15,
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? Colors.blue[800]
                                      : Colors.grey[400],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 60),
                          FocusableControlBuilder(
                            onPressed: _togglePause,
                            builder: (context, control) {
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                width: 140,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: control.isFocused ? Colors.grey[200] : Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: .5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 150),
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                      child: Icon(
                                        _isPaused ? Icons.play_arrow : Icons.pause,
                                        key: ValueKey<bool>(_isPaused),
                                        size: 24,
                                        color:_isPaused?Colors.red: Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 150),
                                      child: Text(
                                        _isPaused ? 'RESUME' : 'PAUSE',
                                        key: ValueKey<bool>(_isPaused),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    FocusableControlBuilder(
                      onPressed: _goToNextPage,
                      builder: (context, control) {
                        return Container(
                          width: 100,
                          height: 70,
                          decoration: BoxDecoration(
                            color: control.isFocused ? Colors.blue[800] : Colors.blue[200],
                            borderRadius: BorderRadius.circular(10),
                            border: control.isFocused
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 36,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}