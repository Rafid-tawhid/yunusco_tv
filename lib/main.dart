import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yunusco_ppt_tv/screens/dashboard_screen.dart';
import 'package:yunusco_ppt_tv/temp/stl.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(1920, 1080), // Match your design resolution
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Yunusco BD Ltd',
          debugShowCheckedModeBanner: false,
          builder: FToastBuilder(),
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const SlideDashboardScreen(),
          //home: const ProPrctice(),
        );
      },
    );
  }
}
