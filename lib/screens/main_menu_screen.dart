import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yunusco_ppt_tv/screens/report_slider_screen.dart';

import 'item_list_screen.dart';



class TVMenuScreen extends StatefulWidget {
  const TVMenuScreen({super.key});

  @override
  State<TVMenuScreen> createState() => _TVMenuScreenState();
}

class _TVMenuScreenState extends State<TVMenuScreen> {
  final FocusNode _focusNode = FocusNode();
  int _selectedIndex = 0;
  final int _columns = 3;

  final List<MenuItem> menuItems = [
    MenuItem(
      title: 'Strength',
      icon: Icons.people_outline,
      color: Colors.blueAccent,
      description: 'Employee management, Designations, Attendance tracking',
    ),
    MenuItem(
      title: 'Production',
      icon: Icons.factory_outlined,
      color: Colors.greenAccent,
      description: 'Line efficiency, Output tracking, Quality control',
    ),
    MenuItem(
      title: 'Inventory',
      icon: Icons.inventory_outlined,
      color: Colors.orangeAccent,
      description: 'Fabric stock, Trims, Finished goods management',
    ),
    MenuItem(
      title: 'Machinery',
      icon: Icons.build_outlined,
      color: Colors.purpleAccent,
      description: 'Equipment status, Maintenance schedules',
    ),
    MenuItem(
      title: 'Orders',
      icon: Icons.list_alt_outlined,
      color: Colors.pinkAccent,
      description: 'Customer orders, Production planning',
    ),
    MenuItem(
      title: 'Quality',
      icon: Icons.question_answer,
      color: Colors.tealAccent,
      description: 'Inspection reports, Defect tracking',
    ),
    MenuItem(
      title: 'Wages',
      icon: Icons.attach_money_outlined,
      color: Colors.yellowAccent,
      description: 'Payroll, Piece-rate calculations',
    ),
    MenuItem(
      title: 'Reports',
      icon: Icons.analytics_outlined,
      color: Colors.redAccent,
      description: 'Daily production, Efficiency analytics',
    ),
    MenuItem(
      title: 'Settings',
      icon: Icons.settings_outlined,
      color: Colors.grey,
      description: 'System configuration, User management',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          if (_selectedIndex < menuItems.length - 1) {
            _selectedIndex++;
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          if (_selectedIndex > 0) {
            _selectedIndex--;
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          if (_selectedIndex + _columns < menuItems.length) {
            _selectedIndex += _columns;
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          if (_selectedIndex - _columns >= 0) {
            _selectedIndex -= _columns;
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        _navigateToCategory(menuItems[_selectedIndex].title,_selectedIndex);
      }
    }
  }

  void _navigateToCategory(String category,int index) {
    if(index==0){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>UserListScreen()));
    }
    if(index==1){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>FactoryReportSlider()));
    }
    // In a real app, you would navigate to the selected category
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: $category'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: _handleKeyEvent,
        child: Stack(
          children: [
            // Background with gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F0C29),
                    Color(0xFF302B63),
                    Color(0xFF24243E),
                  ],
                ),
              ),
            ),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(60, 60, 60, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Management Report',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          menuItems[_selectedIndex].description,
                          key: ValueKey<int>(_selectedIndex),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                          ),
                        ),
                      )

                    ],
                  ),
                ),

                // Menu Items Grid
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 1000, // Fixed width for the grid
                      child: GridView.builder(
                        padding: const EdgeInsets.all(40),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _columns,
                          crossAxisSpacing: 40,
                          mainAxisSpacing: 40,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: menuItems.length,
                        itemBuilder: (context, index) {
                          return Focus(
                            focusNode: FocusNode(skipTraversal: true),
                            canRequestFocus: false,
                            child: Builder(
                              builder: (context) {
                                final isSelected = _selectedIndex == index;
                                if (isSelected) {
                                  // This makes sure the selected item is always visible
                                  Future.delayed(Duration.zero, () {
                                    Scrollable.ensureVisible(
                                      context,
                                      alignment: 0.5,
                                      duration: const Duration(milliseconds: 300),
                                    );
                                  });
                                }
                                return _buildMenuItem(
                                  menuItems[index],
                                  isSelected,
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = index;
                                    });
                                    _navigateToCategory(menuItems[index].title,index);
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
            color: item.color,
            width: 4,
          )
              : null,
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: item.color.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: isSelected ? 80 : 70,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: isSelected ? 32 : 28,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'SELECT',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });
}