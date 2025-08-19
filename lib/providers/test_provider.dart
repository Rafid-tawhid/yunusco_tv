import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yunusco_ppt_tv/models/item_model.dart';

final itemProvider = StateNotifierProvider<ItemNotifier, FavouriteState>((ref) {
  return ItemNotifier();
});

class ItemNotifier extends StateNotifier<FavouriteState> {
  ItemNotifier() : super(FavouriteState(allItems: [], filteredItems: [], search: ''));

  void addItem() {
    final List<ItemModel> itemList = [
      ItemModel(id: 1, name: 'T-Shirt', fav: true),
      ItemModel(id: 2, name: 'Jeans', fav: false),
      ItemModel(id: 3, name: 'Jacket', fav: true),
      ItemModel(id: 4, name: 'Sneakers', fav: false),
      ItemModel(id: 5, name: 'Cap', fav: false),
      ItemModel(id: 6, name: 'Hoodie', fav: true),
      ItemModel(id: 7, name: 'Socks', fav: false),
      ItemModel(id: 8, name: 'Backpack', fav: true),
      ItemModel(id: 9, name: 'Belt', fav: false),
      ItemModel(id: 10, name: 'Sunglasses', fav: true),
    ];

    state = state.copyWith(allItems: itemList.toList(), filteredItems: itemList.toList());
  }

  List<ItemModel> _filterItems(List<ItemModel> list, String query) {
    if (query.isEmpty) {
      return list;
    }

    return list.where((e) => e.name.toLowerCase().contains(query)).toList();
  }

  void filterList(String query) {
    state = state.copyWith(filteredItems: _filterItems(state.allItems, query));
  }
}

class FavouriteState {
  final List<ItemModel> allItems;
  final List<ItemModel> filteredItems;
  final String search;

  FavouriteState({required this.allItems, required this.filteredItems, required this.search});

  FavouriteState copyWith({List<ItemModel>? allItems, List<ItemModel>? filteredItems, String? search}) {
    return FavouriteState(allItems: allItems ?? this.allItems, filteredItems: filteredItems ?? this.filteredItems, search: search ?? this.search);
  }
}
