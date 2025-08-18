import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/report_provider.dart';
import '../services/constants.dart';

Widget buildInputIssuesSlide(WidgetRef ref) {
  final issuesAsync = ref.watch(inputIssuesProvider);

  return issuesAsync.when(
    loading: () => Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(slides[3]['color']))),
    error: (error, stack) => Center(
      child: Text('Error: $error', style: TextStyle(color: Colors.red[700], fontSize: 18)),
    ),
    data: (issues) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern header with icon
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Effected Lines',
                        style: TextStyle(fontSize: 30.h, fontWeight: FontWeight.w800, color: Colors.orange),
                      ),
                      Text('${issues.length} issues detected', style: TextStyle(fontSize: 20.h, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Text('${issues.length}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 22.h),),
                SizedBox(width: 8.h,),
                issues.length==1?Text('Line effected',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 22.h),):Text('Lines effected',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 22.h),),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Modern card with issues list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  child: issues.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                              const SizedBox(height: 16),
                              Text('No input issues found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(top: 8.h),
                          itemCount: issues.length,
                          separatorBuilder: (context, index) => Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final issue = issues[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Issue type indicator
                                  Container(
                                    width: 4,
                                    height: 48.h,
                                    decoration: BoxDecoration(color: _getIssueTypeColor(issue.inputRelatedIssueTypeId!.toInt()), borderRadius: BorderRadius.circular(2)),
                                  ),
                                  SizedBox(width: 12.h),

                                  // Issue details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(issue.inputRelatedIssueName ?? 'Unknown Issue', style:  TextStyle(fontSize: 20.h, fontWeight: FontWeight.w600)),
                                        SizedBox(height: 4.h),
                                        Row(
                                          children: [
                                            // Issue type chip
                                            Container(
                                              padding:  EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.h),
                                              decoration: BoxDecoration(color: _getIssueTypeColor(issue.inputRelatedIssueTypeId!.toInt()).withOpacity(0.1), borderRadius: BorderRadius.circular(12.h)),
                                              child: Text(
                                                _getIssueTypeName(issue.inputRelatedIssueTypeId!.toInt()),
                                                style: TextStyle(fontSize: 16.h, fontWeight: FontWeight.w600, color: _getIssueTypeColor(issue.inputRelatedIssueTypeId!.toInt())),
                                              ),
                                            ),
                                             SizedBox(width: 8.h),

                                            // Line info
                                            Icon(Icons.alt_route_rounded, size: 14, color: Colors.grey[500]),
                                            const SizedBox(width: 4),
                                            Text(issue.inputIssueDate??'',style: TextStyle(fontSize: 16.h,),)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Action button
                                  Text(issue.lineName ?? 'N/A', style: TextStyle(fontSize: 26.h, color: Colors.black,fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Color _getIssueTypeColor(int? typeId) {
  return Colors.blue;
  switch (typeId ?? 0) {
    case 1:
      return Colors.orange;
    case 2:
      return Colors.red;
    case 3:
      return Colors.blue;
    case 4:
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

String _getIssueTypeName(int? typeId) {
  return 'Info';
  switch (typeId ?? 0) {
    case 1:
      return 'Warning';
    case 2:
      return 'Error';
    case 3:
      return 'Info';
    case 4:
      return 'Critical';
    default:
      return 'Info';
  }
}
