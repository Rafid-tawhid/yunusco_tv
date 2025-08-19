import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_ppt_tv/providers/test_provider.dart';

class ProPrctice extends ConsumerWidget {
  const ProPrctice({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final pp=ref.watch(itemProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
         ref.read(itemProvider.notifier).addItem('Rafid');
        },
      ),
      body: pp.isEmpty?Center(child: Text('NONE'),):
      ListView.builder(
        itemCount: pp.length,
        itemBuilder: (BuildContext context, int index) {
          final item=pp[index];
          return ListTile(
            title: Text(item.name),
          );
        },
      ),
    );
  }
}
