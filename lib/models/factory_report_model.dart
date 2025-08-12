class FactoryReportModel {
  FactoryReportModel({
      String? productionDate, 
      String? itemName, 
      num? totalLine, 
      num? quantity, 
      num? averageEfficiency,}){
    _productionDate = productionDate;
    _itemName = itemName;
    _totalLine = totalLine;
    _quantity = quantity;
    _averageEfficiency = averageEfficiency;
}

  FactoryReportModel.fromJson(dynamic json) {
    _productionDate = json['ProductionDate'];
    _itemName = json['ItemName'];
    _totalLine = json['TotalLine'];
    _quantity = json['Quantity'];
    _averageEfficiency = json['AverageEfficiency'];
  }
  String? _productionDate;
  String? _itemName;
  num? _totalLine;
  num? _quantity;
  num? _averageEfficiency;
FactoryReportModel copyWith({  String? productionDate,
  String? itemName,
  num? totalLine,
  num? quantity,
  num? averageEfficiency,
}) => FactoryReportModel(  productionDate: productionDate ?? _productionDate,
  itemName: itemName ?? _itemName,
  totalLine: totalLine ?? _totalLine,
  quantity: quantity ?? _quantity,
  averageEfficiency: averageEfficiency ?? _averageEfficiency,
);
  String? get productionDate => _productionDate;
  String? get itemName => _itemName;
  num? get totalLine => _totalLine;
  num? get quantity => _quantity;
  num? get averageEfficiency => _averageEfficiency;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ProductionDate'] = _productionDate;
    map['ItemName'] = _itemName;
    map['TotalLine'] = _totalLine;
    map['Quantity'] = _quantity;
    map['AverageEfficiency'] = _averageEfficiency;
    return map;
  }

}