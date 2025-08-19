// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:yunusco_ppt_tv/services/constants.dart';
// import '../models/input_issue_model.dart';
// import '../providers/report_provider.dart';
//
// class InputIssuesScreen extends ConsumerWidget {
//   const InputIssuesScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final inputIssuesAsync = ref.watch(inputIssuesProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Input Related Issues"),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: myColors.primaryColor,
//         foregroundColor: Colors.white,
//       ),
//       body: Container(
//
//         child: inputIssuesAsync.when(
//           loading: () => const Center(
//             child: CircularProgressIndicator(
//               color: Colors.white,
//               strokeWidth: 3,
//             ),
//           ),
//           error: (err, stack) => Center(
//             child: Text(
//               "Error: $err",
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//           data: (issues) {
//             if (issues.isEmpty) {
//               return Center(
//                 child: Text(
//                   "No input-related issues found",
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 18,
//                   ),
//                 ),
//               );
//             }
//             else {
//               return ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: issues.length,
//                 itemBuilder: (context, index) {
//                   final issue = issues[index];
//                   return _buildIssueCard(context, issue);
//                 },
//               );
//             }
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Add your action here
//         },
//         backgroundColor: Colors.amber,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
//
//   Widget _buildIssueCard(BuildContext context, InputIssueModel issue) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Card(
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         color: Colors.white.withOpacity(0.9),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       issue.inputRelatedIssueName ?? 'Unnamed Issue',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.deepPurple,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   // Container(
//                   //   padding: const EdgeInsets.symmetric(
//                   //     horizontal: 8,
//                   //     vertical: 4,
//                   //   ),
//                   //   decoration: BoxDecoration(
//                   //     color: _getStatusColor(issue.status ?? 0),
//                   //     borderRadius: BorderRadius.circular(12),
//                   //   ),
//                   //   child: Text(
//                   //     _getStatusText(issue.status ?? 0),
//                   //     style: const TextStyle(
//                   //       color: Colors.white,
//                   //       fontSize: 12,
//                   //       fontWeight: FontWeight.bold,
//                   //     ),
//                   //   ),
//                   // ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               _buildInfoRow(
//                 Icons.calendar_today,
//                 issue.inputIssueDate ?? 'No Date',
//                 Colors.blueAccent,
//               ),
//               const SizedBox(height: 8),
//               _buildInfoRow(
//                 Icons.engineering,
//                 issue.lineName ?? 'No Line Info',
//                 Colors.green,
//               ),
//               const SizedBox(height: 8),
//               _buildInfoRow(
//                 Icons.category,
//                 issue.inputRelatedIssueName ?? 'No Issue Type',
//                 Colors.orange,
//               ),
//               const SizedBox(height: 8),
//               _buildInfoRow(
//                 Icons.confirmation_number,
//                 'ID: ${issue.inputRelatedIssueTypeId.toString()}',
//                 Colors.purple,
//               ),
//               const SizedBox(height: 12),
//               // if (issue.description?.isNotEmpty ?? false)
//               //   Column(
//               //     crossAxisAlignment: CrossAxisAlignment.start,
//               //     children: [
//               //       const Divider(),
//               //       const SizedBox(height: 8),
//               //       Text(
//               //         issue.description!,
//               //         style: TextStyle(
//               //           color: Colors.grey[700],
//               //           fontSize: 14,
//               //         ),
//               //       ),
//               //     ],
//               //   ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(4),
//           decoration: BoxDecoration(
//             color: iconColor.withOpacity(0.2),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             icon,
//             size: 18,
//             color: iconColor,
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             text,
//             style: TextStyle(
//               color: Colors.grey[800],
//               fontSize: 14,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Color _getStatusColor(int status) {
//     switch (status) {
//       case 1:
//         return Colors.green;
//       case 2:
//         return Colors.orange;
//       case 3:
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   String _getStatusText(int status) {
//     switch (status) {
//       case 1:
//         return 'RESOLVED';
//       case 2:
//         return 'IN PROGRESS';
//       case 3:
//         return 'CRITICAL';
//       default:
//         return 'UNKNOWN';
//     }
//   }
// }