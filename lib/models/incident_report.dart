class IncidentReport {
  final int? reportId;
  final int stationId;
  final int typeId;
  final String reporterName;
  final String description;
  final String? evidencePhoto;
  final String timestamp;
  final String? aiResult;
  final double? aiConfidence;
  
  // Joined fields
  final String? stationName;
  final String? zone;
  final String? province;
  final String? typeName;
  final String? severity;

  IncidentReport({
    this.reportId,
    required this.stationId,
    required this.typeId,
    required this.reporterName,
    required this.description,
    this.evidencePhoto,
    required this.timestamp,
    this.aiResult,
    this.aiConfidence,
    this.stationName,
    this.zone,
    this.province,
    this.typeName,
    this.severity,
  });

  factory IncidentReport.fromJson(Map<String, dynamic> json) {
    return IncidentReport(
      reportId: json['report_id'] != null ? (json['report_id'] is int ? json['report_id'] : int.parse(json['report_id'].toString())) : null,
      stationId: json['station_id'] is int ? json['station_id'] : int.parse(json['station_id'].toString()),
      typeId: json['type_id'] is int ? json['type_id'] : int.parse(json['type_id'].toString()),
      reporterName: json['reporter_name'],
      description: json['description'],
      evidencePhoto: json['evidence_photo'],
      timestamp: json['timestamp'],
      aiResult: json['ai_result'],
      aiConfidence: json['ai_confidence'] != null ? double.parse(json['ai_confidence'].toString()) : null,
      stationName: json['station_name'],
      zone: json['zone'],
      province: json['province'],
      typeName: json['type_name'],
      severity: json['severity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (reportId != null) 'report_id': reportId,
      'station_id': stationId,
      'type_id': typeId,
      'reporter_name': reporterName,
      'description': description,
      'evidence_photo': evidencePhoto,
      'timestamp': timestamp,
      'ai_result': aiResult,
      'ai_confidence': aiConfidence,
    };
  }
}
