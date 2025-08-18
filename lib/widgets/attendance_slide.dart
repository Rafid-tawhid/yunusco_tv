import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/employee_attendance_model.dart';
import '../providers/report_provider.dart';
import '../services/constants.dart';

Widget buildDepartmentAttendanceSlide(WidgetRef ref) {
  final attendanceAsync = ref.watch(departmentAttendanceProvider);

  return attendanceAsync.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (error, stack) => Center(
      child: Text('Error: $error', style: const TextStyle(color: Colors.red, fontSize: 18)),
    ),
    data: (departmentData) {
      final totalStats = _calculateTotalStats(departmentData);

      return Column(
        children: [
          // Header with department stats
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.h),
            child: Column(
              children: [
                Text(
                  'Attendance Details',
                  style: TextStyle(fontSize: 28.h, fontWeight: FontWeight.bold, color: slides[1]['color']),
                ),
                AnimatedStatsBar(totalStats: totalStats),
                SizedBox(height: 4.h,)
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin:  EdgeInsets.symmetric(horizontal: 20.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.h),
                child: Column(
                  children: [
                    // Department Header
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.h,vertical: 8.h),
                      decoration: BoxDecoration(
                        color: myColors.primaryColor
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.group, color: Colors.white, size: 32.h),
                          SizedBox(width: 12.h),
                          Text(
                            departmentData.departmentName,
                            style:  TextStyle(fontSize: 22.h, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const Spacer(),
                          Text('${totalStats.sections} Sections', style: const TextStyle(fontSize: 16, color: Colors.white)),
                        ],
                      ),
                    ),

                    // Sections List
                    Expanded(
                      child: ListView.separated(
                        padding:  EdgeInsets.only(top: 8.h),
                        itemCount: departmentData.sections.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final section = departmentData.sections.values.elementAt(index);
                          return AnimatedSectionCard(section: section, index: index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _TotalStats {
  final int present;
  final int absent;
  final int strength;
  final int sections;

  _TotalStats({required this.present, required this.absent, required this.strength, required this.sections});
}

_TotalStats _calculateTotalStats(DepartmentData departmentData) {
  int present = 0;
  int absent = 0;

  departmentData.sections.values.forEach((section) {
    section.employees.forEach((employee) {
      present += employee.present;
      absent += employee.absent;
    });
  });

  return _TotalStats(present: present, absent: absent, strength: present + absent, sections: departmentData.sections.length);
}

class AnimatedStatsBar extends StatelessWidget {
  final _TotalStats totalStats;

  const AnimatedStatsBar({super.key, required this.totalStats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.h)),
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 12.h,vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('Present', totalStats.present, Colors.green, Icons.check_circle),
            _buildStatItem('Absent', totalStats.absent, Colors.red, Icons.cancel),
            _buildStatItem('Total', totalStats.strength, Colors.blue, Icons.people),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color, IconData icon) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(seconds: 1),
      builder: (context, animatedValue, child) {
        return Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Text(
                  animatedValue.toInt().toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        );
      },
    );
  }
}

class AnimatedSectionCard extends StatefulWidget {
  final SectionGroup section;
  final int index;

  const AnimatedSectionCard({super.key, required this.section, required this.index});

  @override
  State<AnimatedSectionCard> createState() => _AnimatedSectionCardState();
}

class _AnimatedSectionCardState extends State<AnimatedSectionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500 + (widget.index * 150)),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sectionStats = _calculateSectionStats(widget.section);

    return ScaleTransition(
      scale: _animation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
        child: Card(
          elevation: 3,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: slides[1]['color'].withOpacity(0.2),
              child: Text(
                '${widget.index + 1}',
                style: TextStyle(color: slides[1]['color'], fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(widget.section.sectionName, style:  TextStyle(fontSize: 22.h, fontWeight: FontWeight.bold)),
            subtitle: Text.rich(
              TextSpan(
                children: [
                   TextSpan(
                    text: 'Present: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16.h, // Increased from 13
                    ),
                  ),
                  TextSpan(
                    text: '${sectionStats.present}, ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.h, // Increased from 13
                    ),
                  ),

                   TextSpan(
                    text: 'Absent: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 16.h, // Increased from 13
                    ),
                  ),
                  TextSpan(
                    text: '${sectionStats.absent}, ',
                    style:  TextStyle(
                      color: Colors.black,
                      fontSize: 16.h, // Increased from 13
                    ),
                  ),

                  const TextSpan(
                    text: 'Strength: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 15, // Increased from 13
                    ),
                  ),
                  TextSpan(
                    text: '${sectionStats.total}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15, // Increased from 13
                    ),
                  ),
                ],
              ),
            ),

            trailing: Chip(
              backgroundColor: _getAttendanceColor(sectionStats.attendanceRate),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Percentage
                  Container(
                    padding:  EdgeInsets.symmetric(horizontal: 6.h, vertical: 2.h),
                    decoration: BoxDecoration( borderRadius: BorderRadius.circular(6)),
                    child: Text('Absenteeism: ${(100-sectionStats.attendanceRate).toStringAsFixed(2)}%', style:  TextStyle(fontSize: 16.h, fontWeight: FontWeight.bold,color: Colors.white)),
                  ),
                ],
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Section summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniStat('Present', sectionStats.present, Colors.green),
                        _buildMiniStat('Absent', sectionStats.absent, Colors.red),
                        _buildMiniStat('Total', sectionStats.total, Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Employees list
                    ...widget.section.employees.map((employee) {
                      final index = widget.section.employees.indexOf(employee);
                      return AnimatedEmployeeRow(employee: employee, index: index);
                    }),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Color _getAttendanceColor(double rate) {
    if (rate > 90) return Colors.blue;
    if (rate > 75) return Colors.orange;
    if (rate > 50) return Colors.red;
    return Colors.red;
  }
}

class _SectionStats {
  final int present;
  final int absent;
  final int total;
  final double attendanceRate;

  _SectionStats({required this.present, required this.absent, required this.total, required this.attendanceRate});
}

_SectionStats _calculateSectionStats(SectionGroup section) {
  int present = 0;
  int absent = 0;

  section.employees.forEach((employee) {
    present += employee.present;
    absent += employee.absent;
  });

  final total = present + absent;
  final attendanceRate = total > 0 ? (present / total * 100) : 0;

  return _SectionStats(present: present, absent: absent, total: total, attendanceRate: attendanceRate.toDouble());
}

class AnimatedEmployeeRow extends StatelessWidget {
  final EmployeeAttendance employee;
  final int index;

  const AnimatedEmployeeRow({super.key, required this.employee, required this.index});

  @override
  Widget build(BuildContext context) {
    final attendancePercent = employee.strength > 0 ? (employee.present / employee.strength * 100) : 0;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, (1 - value) * 20), child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Designation
            Expanded(flex: 2, child: Text(employee.designation, style: const TextStyle(fontSize: 16))),

            // Present/Absent
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    employee.present.toString(),
                    style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  const Text('/', style: TextStyle(fontSize: 16)),
                  Text(employee.strength.toString(), style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),

            // Attendance percentage bar
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: attendancePercent / 100,
                    backgroundColor: Colors.grey[200],
                    color: attendancePercent > 90
                        ? Colors.green
                        : attendancePercent > 75
                        ? Colors.blue
                        : attendancePercent > 50
                        ? Colors.orange
                        : Colors.red,
                    minHeight: 20,
                  ),
                ),
              ),
            ),

            // Percentage text
            SizedBox(
              width: 60,
              child: Text(
                '${attendancePercent.toStringAsFixed(1)}%',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: attendancePercent > 90
                      ? Colors.green
                      : attendancePercent > 75
                      ? Colors.blue
                      : attendancePercent > 50
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
