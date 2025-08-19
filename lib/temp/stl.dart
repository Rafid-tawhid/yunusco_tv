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
         ref.read(itemProvider.notifier).addItem();
        },
      ),
      body: pp.filteredItems.isEmpty?Center(child: Text('NONE'),):
      Column(
        children: [
          Text('TODO'),
          TextField(
            decoration: InputDecoration(
              hint: Text('Search'),
              border: OutlineInputBorder()
            ),
            onChanged: (v){
              ref.read(itemProvider.notifier).filterList(v);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pp.filteredItems.length,
              itemBuilder: (BuildContext context, int index) {
                final item=pp.filteredItems[index];
                return ListTile(
                  title: Text(item.name),
                  trailing: Icon(item.fav?Icons.favorite:Icons.favorite_border),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
