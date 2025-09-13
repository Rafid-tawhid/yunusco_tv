// models/dhu_model.dart
class SectionWiseDHU {
  final String sectionName;
  final double sectionDHU;

  SectionWiseDHU({required this.sectionName, required this.sectionDHU});

  factory SectionWiseDHU.fromJson(Map<String, dynamic> json) {
    return SectionWiseDHU(
      sectionName: json['SectionName'] ?? '',
      sectionDHU: (json['SectionDHU'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class LineWiseDHU {
  final String lineName;
  final double lineDHU;

  LineWiseDHU({required this.lineName, required this.lineDHU});

  factory LineWiseDHU.fromJson(Map<String, dynamic> json) {
    return LineWiseDHU(
      lineName: json['LineName'] ?? '',
      lineDHU: (json['LineDHU'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TotalDHU {
  final double totalDHU;

  TotalDHU({required this.totalDHU});

  factory TotalDHU.fromJson(Map<String, dynamic> json) {
    return TotalDHU(
      totalDHU: (json['TotalDHU'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DHUData {
  final List<SectionWiseDHU> sectionWiseDHU;
  final List<LineWiseDHU> lineWiseDHU;
  final TotalDHU totalDHU;

  DHUData({
    required this.sectionWiseDHU,
    required this.lineWiseDHU,
    required this.totalDHU,
  });

  factory DHUData.fromJson(Map<String, dynamic> json) {
    return DHUData(
      sectionWiseDHU: (json['SectionWiseDHU'] as List? ?? [])
          .map((item) => SectionWiseDHU.fromJson(item))
          .toList(),
      lineWiseDHU: (json['LineWiseDHU'] as List? ?? [])
          .map((item) => LineWiseDHU.fromJson(item))
          .toList(),
      totalDHU: TotalDHU.fromJson(json['TotalDHU'] ?? {}),
    );
  }
}

class DHUResponse {
  final bool success;
  final String message;
  final DHUData data;

  DHUResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DHUResponse.fromJson(Map<String, dynamic> json) {
    return DHUResponse(
      success: json['Success'] ?? false,
      message: json['Message'] ?? '',
      data: DHUData.fromJson(json['Data'] ?? {}),
    );
  }
}