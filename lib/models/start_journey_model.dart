class StartJourneyModel {
  final int? id;
  final bool isOngoing;
  final String clientName;
  final String address;
  final String startLocation;
  final String startReading;
  String startReadingImage;
  final String startedAt;

  StartJourneyModel({
    this.id,
    required this.isOngoing,
    required this.clientName,
    required this.address,
    required this.startReading,
    required this.startedAt,
    required this.startLocation,
    required this.startReadingImage,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "isOngoing": isOngoing.toString(),
    "clientName": clientName,
    "address": address,
    "startReading": startReading,
    "startedAt": startedAt,
    "startLocation": startLocation,
    "startReadingImage": startReadingImage,
  };

  factory StartJourneyModel.fromJson(Map<String, dynamic> json) => StartJourneyModel(
    id: json["id"],
    isOngoing: json["isOngoing"] == "true" ? true : false,
    clientName: json["clientName"],
    address: json["address"],
    startReading: json["startReading"],
    startedAt: json["startedAt"],
    startLocation: json["startLocation"],
    startReadingImage: json["startReadingImage"],
  );
}
