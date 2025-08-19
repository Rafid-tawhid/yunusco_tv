import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_ppt_tv/models/item_model.dart';

final itemProvider=StateNotifierProvider<ItemNotifier,List<ItemModel>>((ref){
  return ItemNotifier();
});


class ItemNotifier extends StateNotifier<List<ItemModel>>{
  ItemNotifier():super([]);

  void addItem(String name){
    final item=ItemModel(id: DateTime.now().toString(), name: name);
    state.add(item);
    state=state.toList();
  }
}