class EmployeeAttendance {
  final String departmentName;
  final String sectionName;
  final String designation;
  final int present;
  final int absent;
  final int strength;
  final double absentPercent;

  EmployeeAttendance({
    required this.departmentName,
    required this.sectionName,
    required this.designation,
    required this.present,
    required this.absent,
    required this.strength,
    required this.absentPercent,
  });

  factory EmployeeAttendance.fromJson(Map<String, dynamic> json) {
    return EmployeeAttendance(
      departmentName: json['DepartmentName'] as String,
      sectionName: json['SectionName'] as String,
      designation: json['Designation'] as String,
      present: json['Present'] as int,
      absent: json['Absent'] as int,
      strength: json['Strength'] as int,
      absentPercent: (json['AbsentPercent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DepartmentName': departmentName,
      'SectionName': sectionName,
      'Designation': designation,
      'Present': present,
      'Absent': absent,
      'Strength': strength,
      'AbsentPercent': absentPercent,
    };
  }
}

class SectionGroup {
  final String sectionName;
  final List<EmployeeAttendance> employees;

  SectionGroup({
    required this.sectionName,
    required this.employees,
  });

  factory SectionGroup.fromEmployeeList(List<EmployeeAttendance> employees) {
    if (employees.isEmpty) throw ArgumentError("Employees list cannot be empty");
    return SectionGroup(
      sectionName: employees.first.sectionName,
      employees: employees,
    );
  }

  @override
  String toString() {
    return 'SectionGroup{sectionName: $sectionName, employees: $employees}';
  }


}

class DepartmentData {
  final String departmentName;
  final Map<String, SectionGroup> sections;

  DepartmentData({
    required this.departmentName,
    required this.sections,
  });

  @override
  String toString() {
    return 'DepartmentData{departmentName: $departmentName, sections: $sections}';
  }

  factory DepartmentData.fromEmployeeList(List<EmployeeAttendance> employees) {
    if (employees.isEmpty) throw ArgumentError("Employees list cannot be empty");

    final departmentName = employees.first.departmentName;
    final grouped = groupBySection(employees);

    final sections = grouped.map((sectionName, employees) => MapEntry(
      sectionName,
      SectionGroup.fromEmployeeList(employees),
    ));

    return DepartmentData(
      departmentName: departmentName,
      sections: sections,
    );
  }

  static Map<String, List<EmployeeAttendance>> groupBySection(
      List<EmployeeAttendance> employees,
      ) {
    final Map<String, List<EmployeeAttendance>> groupedData = {};

    for (final employee in employees) {
      groupedData
          .putIfAbsent(employee.sectionName, () => [])
          .add(employee);
    }

    return groupedData;
  }
}