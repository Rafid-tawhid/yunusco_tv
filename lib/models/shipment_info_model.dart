class ShipmentInfoModel {
  ShipmentInfoModel({
      String? monthYear, 
      num? delivered, 
      num? notDelivered, 
      num? beforeShiped, 
      num? timelyShiped, 
      num? oneWeekDelay, 
      num? twoWeekDelay, 
      num? moreTwoWeekDelay,}){
    _monthYear = monthYear;
    _delivered = delivered;
    _notDelivered = notDelivered;
    _beforeShiped = beforeShiped;
    _timelyShiped = timelyShiped;
    _oneWeekDelay = oneWeekDelay;
    _twoWeekDelay = twoWeekDelay;
    _moreTwoWeekDelay = moreTwoWeekDelay;
}

  ShipmentInfoModel.fromJson(dynamic json) {
    _monthYear = json['MonthYear'];
    _delivered = json['Delivered'];
    _notDelivered = json['NotDelivered'];
    _beforeShiped = json['BeforeShiped'];
    _timelyShiped = json['TimelyShiped'];
    _oneWeekDelay = json['OneWeekDelay'];
    _twoWeekDelay = json['TwoWeekDelay'];
    _moreTwoWeekDelay = json['MoreTwoWeekDelay'];
  }
  String? _monthYear;
  num? _delivered;
  num? _notDelivered;
  num? _beforeShiped;
  num? _timelyShiped;
  num? _oneWeekDelay;
  num? _twoWeekDelay;
  num? _moreTwoWeekDelay;
ShipmentInfoModel copyWith({  String? monthYear,
  num? delivered,
  num? notDelivered,
  num? beforeShiped,
  num? timelyShiped,
  num? oneWeekDelay,
  num? twoWeekDelay,
  num? moreTwoWeekDelay,
}) => ShipmentInfoModel(  monthYear: monthYear ?? _monthYear,
  delivered: delivered ?? _delivered,
  notDelivered: notDelivered ?? _notDelivered,
  beforeShiped: beforeShiped ?? _beforeShiped,
  timelyShiped: timelyShiped ?? _timelyShiped,
  oneWeekDelay: oneWeekDelay ?? _oneWeekDelay,
  twoWeekDelay: twoWeekDelay ?? _twoWeekDelay,
  moreTwoWeekDelay: moreTwoWeekDelay ?? _moreTwoWeekDelay,
);
  String? get monthYear => _monthYear;
  num? get delivered => _delivered;
  num? get notDelivered => _notDelivered;
  num? get beforeShiped => _beforeShiped;
  num? get timelyShiped => _timelyShiped;
  num? get oneWeekDelay => _oneWeekDelay;
  num? get twoWeekDelay => _twoWeekDelay;
  num? get moreTwoWeekDelay => _moreTwoWeekDelay;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['MonthYear'] = _monthYear;
    map['Delivered'] = _delivered;
    map['NotDelivered'] = _notDelivered;
    map['BeforeShiped'] = _beforeShiped;
    map['TimelyShiped'] = _timelyShiped;
    map['OneWeekDelay'] = _oneWeekDelay;
    map['TwoWeekDelay'] = _twoWeekDelay;
    map['MoreTwoWeekDelay'] = _moreTwoWeekDelay;
    return map;
  }

}