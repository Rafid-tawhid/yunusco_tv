import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HelperClass {

  static showMessage({required String message,double? size, Color? color}){
    Fluttertoast.showToast(
        msg:  message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: color??Colors.black54,
        textColor: Colors.white,
        fontSize: size??16.0
    );
  }


  Map<String, List<Map<String, dynamic>>> groupBySection(List<Map<String, dynamic>> data) {
    final Map<String, List<Map<String, dynamic>>> groupedData = {};

    for (var item in data) {
      final sectionName = item['SectionName'] as String;

      if (!groupedData.containsKey(sectionName)) {
        groupedData[sectionName] = [];
      }

      groupedData[sectionName]!.add(item);
    }

    return groupedData;
  }
}