import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/item_provider.dart';

class UserDetailScreen extends ConsumerWidget {
  final int userId;

  const UserDetailScreen({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDetailProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text('User Details')),
      body: userAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (user) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${user.name}', style: TextStyle(fontSize: 20)),
              Text('Email: ${user.email}'),
              Text('Phone: ${user.phone}'),
              Text('Address: ${user.address.street}, ${user.address.city}'),
            ],
          ),
        ),
      ),
    );
  }
}