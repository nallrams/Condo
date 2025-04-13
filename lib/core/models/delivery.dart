class Delivery {
  final String id;
  final String userId;
  final String trackingNumber;
  final String courierName;
  final String status; // pending, delivered, collected, returned
  final DateTime expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final DateTime? collectionDate;
  final String? collectedBy;
  final String? notes;
  final String? packageSize; // small, medium, large
  final String? packageDescription;
  final String? senderInfo;

  Delivery({
    required this.id,
    required this.userId,
    required this.trackingNumber,
    required this.courierName,
    required this.status,
    required this.expectedDeliveryDate,
    this.actualDeliveryDate,
    this.collectionDate,
    this.collectedBy,
    this.notes,
    this.packageSize,
    this.packageDescription,
    this.senderInfo,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      userId: json['userId'],
      trackingNumber: json['trackingNumber'],
      courierName: json['courierName'],
      status: json['status'],
      expectedDeliveryDate: DateTime.parse(json['expectedDeliveryDate']),
      actualDeliveryDate: json['actualDeliveryDate'] != null
          ? DateTime.parse(json['actualDeliveryDate'])
          : null,
      collectionDate: json['collectionDate'] != null
          ? DateTime.parse(json['collectionDate'])
          : null,
      collectedBy: json['collectedBy'],
      notes: json['notes'],
      packageSize: json['packageSize'],
      packageDescription: json['packageDescription'],
      senderInfo: json['senderInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'trackingNumber': trackingNumber,
      'courierName': courierName,
      'status': status,
      'expectedDeliveryDate': expectedDeliveryDate.toIso8601String(),
      'actualDeliveryDate': actualDeliveryDate?.toIso8601String(),
      'collectionDate': collectionDate?.toIso8601String(),
      'collectedBy': collectedBy,
      'notes': notes,
      'packageSize': packageSize,
      'packageDescription': packageDescription,
      'senderInfo': senderInfo,
    };
  }

  Delivery copyWith({
    String? id,
    String? userId,
    String? trackingNumber,
    String? courierName,
    String? status,
    DateTime? expectedDeliveryDate,
    DateTime? actualDeliveryDate,
    DateTime? collectionDate,
    String? collectedBy,
    String? notes,
    String? packageSize,
    String? packageDescription,
    String? senderInfo,
  }) {
    return Delivery(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      courierName: courierName ?? this.courierName,
      status: status ?? this.status,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      collectionDate: collectionDate ?? this.collectionDate,
      collectedBy: collectedBy ?? this.collectedBy,
      notes: notes ?? this.notes,
      packageSize: packageSize ?? this.packageSize,
      packageDescription: packageDescription ?? this.packageDescription,
      senderInfo: senderInfo ?? this.senderInfo,
    );
  }
}
