class EndJourneyModel {
  final int id;
  final String endReading;
  final String endLocation;
  final String endReadingImage;
  final bool isOngoing;
  final String endedAt;

  EndJourneyModel({
    required this.id,
    required this.endReading,
    required this.endLocation,
    required this.endReadingImage,
    required this.isOngoing,
    required this.endedAt,
  });

  factory EndJourneyModel.fromJson(Map<String, dynamic> json) {
    return EndJourneyModel(
      id: json['id'],
      endReading: json['endReading'],
      endLocation: json['endLocation'],
      endReadingImage: json['endReadingImage'],
      endedAt: json['endedAt'],
      isOngoing: json["isOngoing"] == "true" ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'endReading': endReading,
      'endLocation': endLocation,
      'endedAt': endedAt,
      "isOngoing": isOngoing.toString(),
      'endReadingImage': endReadingImage,
    };
  }
}
