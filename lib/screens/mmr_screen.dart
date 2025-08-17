import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_ppt_tv/services/constants.dart';
import '../models/input_issue_model.dart';
import '../providers/report_provider.dart';

class MMRScreen extends ConsumerWidget {
  const MMRScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputIssuesAsync = ref.watch(mmrProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("MMR Screen"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: myColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(

        child: inputIssuesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          error: (err, stack) => Center(
            child: Text(
              "Error: $err",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          data: (issues) {
            if (issues.toString()=='') {
              return Center(
                child: Text(
                  "No input-related issues found",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 18,
                  ),
                ),
              );
            }

            return Center(child: Card(child: Text(issues.toString()),),);
          },
        ),
      ),

    );
  }

}