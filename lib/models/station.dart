class Station {
  final int stationId;
  final String stationName;
  final String zone;
  final String province;

  Station({
    required this.stationId,
    required this.stationName,
    required this.zone,
    required this.province,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      stationId: json['station_id'] is int ? json['station_id'] : int.parse(json['station_id'].toString()),
      stationName: json['station_name'],
      zone: json['zone'],
      province: json['province'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'station_id': stationId,
      'station_name': stationName,
      'zone': zone,
      'province': province,
    };
  }
}
