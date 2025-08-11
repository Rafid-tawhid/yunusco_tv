import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yunusco_ppt_tv/report_slider_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yunusco BD Ltd',
      debugShowCheckedModeBanner: false,
      builder: FToastBuilder(),
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FactoryReportSlider(),
    );
  }
}
