class ItemModel{

  final int id;
  final String name;
  final bool fav;

  ItemModel({required this.id,required this.name,required this.fav});

  ItemModel copyWith({
    String? name,
    int? id,
    bool? fav
}){
    return ItemModel(name: name??this.name, id: id??this.id, fav: fav??this.fav);
  }

}