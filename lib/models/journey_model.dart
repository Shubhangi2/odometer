class JourneyModel {
  final int id;
  final bool isOngoing;
  final String clientName;
  final String address;
  final String startLocation;
  final String startReading;
  final String startReadingImage;
  final String startedAt;
  final String? endedAt;
  final String? endReading;
  final String? endLocation;
  final String? endReadingImage;
  final bool isSyncedOnline;

  JourneyModel({
    required this.id,
    required this.isOngoing,
    required this.clientName,
    required this.address,
    required this.startReading,
    required this.startedAt,
    required this.startLocation,
    required this.startReadingImage,
    required this.endedAt,
    required this.endReading,
    required this.endLocation,
    required this.endReadingImage,
    required this.isSyncedOnline,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "isOngoing": isOngoing.toString(),
    "clientName": clientName,
    "address": address,
    "startReading": startReading,
    "startedAt": startedAt,
    "startLocation": startLocation,
    "endedAt": endedAt,
    "endReading": endReading,
    "endLocation": endLocation,
    'isSyncedOnline': isSyncedOnline.toString(),
    "startReadingImage": startReadingImage,
    "endReadingImage": endReadingImage,
  };

  factory JourneyModel.fromJson(Map<String, dynamic> json) => JourneyModel(
    id: json["id"],
    isOngoing: json["isOngoing"] == "true" ? true : false,
    clientName: json["clientName"] ?? '',
    address: json["address"] ?? '',
    startReading: json["startReading"] ?? '',
    startedAt: json["startedAt"] ?? '',
    startLocation: json["startLocation"] ?? '',
    startReadingImage: json["startReadingImage"] ?? '',
    endedAt: json["endedAt"] ?? '',
    endReading: json["endReading"] ?? '',
    endLocation: json["endLocation"] ?? '',
    endReadingImage: json["endReadingImage"] ?? '',
    isSyncedOnline: json['isSyncedOnline'] == "true" ? true : false,
  );
}
