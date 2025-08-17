class InputIssueModel {
  InputIssueModel({
      num? inputIssueId, 
      String? inputIssueDate, 
      String? inputRelatedIssueName, 
      num? inputRelatedIssueTypeId, 
      String? lineName,}){
    _inputIssueId = inputIssueId;
    _inputIssueDate = inputIssueDate;
    _inputRelatedIssueName = inputRelatedIssueName;
    _inputRelatedIssueTypeId = inputRelatedIssueTypeId;
    _lineName = lineName;
}

  InputIssueModel.fromJson(dynamic json) {
    _inputIssueId = json['InputIssueId'];
    _inputIssueDate = json['InputIssueDate'];
    _inputRelatedIssueName = json['InputRelatedIssueName'];
    _inputRelatedIssueTypeId = json['InputRelatedIssueTypeId'];
    _lineName = json['LineName'];
  }
  num? _inputIssueId;
  String? _inputIssueDate;
  String? _inputRelatedIssueName;
  num? _inputRelatedIssueTypeId;
  String? _lineName;
InputIssueModel copyWith({  num? inputIssueId,
  String? inputIssueDate,
  String? inputRelatedIssueName,
  num? inputRelatedIssueTypeId,
  String? lineName,
}) => InputIssueModel(  inputIssueId: inputIssueId ?? _inputIssueId,
  inputIssueDate: inputIssueDate ?? _inputIssueDate,
  inputRelatedIssueName: inputRelatedIssueName ?? _inputRelatedIssueName,
  inputRelatedIssueTypeId: inputRelatedIssueTypeId ?? _inputRelatedIssueTypeId,
  lineName: lineName ?? _lineName,
);
  num? get inputIssueId => _inputIssueId;
  String? get inputIssueDate => _inputIssueDate;
  String? get inputRelatedIssueName => _inputRelatedIssueName;
  num? get inputRelatedIssueTypeId => _inputRelatedIssueTypeId;
  String? get lineName => _lineName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InputIssueId'] = _inputIssueId;
    map['InputIssueDate'] = _inputIssueDate;
    map['InputRelatedIssueName'] = _inputRelatedIssueName;
    map['InputRelatedIssueTypeId'] = _inputRelatedIssueTypeId;
    map['LineName'] = _lineName;
    return map;
  }

}