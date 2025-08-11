// model/factory_report.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FactoryReport {
  final String title;
  final String value;
  final String change;
  final IconData icon;

  final Color color;

  FactoryReport({
    required this.title,
    required this.value,
    required this.change,
    required this.color,
    required this.icon,
  });

  factory FactoryReport.fromJson(Map<String, dynamic> json) {
    return FactoryReport(
      title: json['title'],
      value: json['value'],
      change: json['change'],
      icon: json['icon'],
      color: _getColorFromHex(json['color']),
    );
  }



  static Color _getColorFromHex(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xff')));
  }
}
