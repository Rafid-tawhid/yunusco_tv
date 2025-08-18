import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Input Issues',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.orange),
                    ),
                    Text('${issues.length} issues detected', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

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
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: issues.length,
                          separatorBuilder: (context, index) => Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final issue = issues[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Issue type indicator
                                  Container(
                                    width: 4,
                                    height: 48,
                                    decoration: BoxDecoration(color: _getIssueTypeColor(issue.inputRelatedIssueTypeId!.toInt()), borderRadius: BorderRadius.circular(2)),
                                  ),
                                  const SizedBox(width: 12),

                                  // Issue details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(issue.inputRelatedIssueName ?? 'Unknown Issue', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            // Issue type chip
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: _getIssueTypeColor(issue.inputRelatedIssueTypeId!.toInt()).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                              child: Text(
                                                _getIssueTypeName(issue.inputRelatedIssueTypeId!.toInt()),
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _getIssueTypeColor(issue.inputRelatedIssueTypeId!.toInt())),
                                              ),
                                            ),
                                            const SizedBox(width: 8),

                                            // Line info
                                            Icon(Icons.alt_route_rounded, size: 14, color: Colors.grey[500]),
                                            const SizedBox(width: 4),
                                            Text(issue.inputIssueDate??'')
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Action button
                                  Text(issue.lineName ?? 'N/A', style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold)),
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
