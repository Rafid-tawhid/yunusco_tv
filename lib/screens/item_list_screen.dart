import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_ppt_tv/screens/user_dts.dart';

import '../providers/item_provider.dart';

class UserListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: usersAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (_, index) => ListTile(
            title: Text(users[index].name),
            subtitle: Text(users[index].email),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserDetailScreen(userId: users[index].id),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.refresh(usersProvider),
        child: Icon(Icons.refresh),
      ),
    );
  }
}
