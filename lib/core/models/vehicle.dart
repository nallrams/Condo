class Vehicle {
  final String id;
  final String userId;
  final String licensePlate;
  final String make;
  final String model;
  final String color;
  final String type; // car, motorcycle, truck, etc.
  final bool isPrimary;
  final bool isRegistered;
  final String? parkingSlot;
  final DateTime? registrationDate;
  final Map<String, dynamic>? additionalInfo;

  Vehicle({
    required this.id,
    required this.userId,
    required this.licensePlate,
    required this.make,
    required this.model,
    required this.color,
    required this.type,
    required this.isPrimary,
    required this.isRegistered,
    this.parkingSlot,
    this.registrationDate,
    this.additionalInfo,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      userId: json['userId'],
      licensePlate: json['licensePlate'],
      make: json['make'],
      model: json['model'],
      color: json['color'],
      type: json['type'],
      isPrimary: json['isPrimary'],
      isRegistered: json['isRegistered'],
      parkingSlot: json['parkingSlot'],
      registrationDate: json['registrationDate'] != null
          ? DateTime.parse(json['registrationDate'])
          : null,
      additionalInfo: json['additionalInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'licensePlate': licensePlate,
      'make': make,
      'model': model,
      'color': color,
      'type': type,
      'isPrimary': isPrimary,
      'isRegistered': isRegistered,
      'parkingSlot': parkingSlot,
      'registrationDate': registrationDate?.toIso8601String(),
      'additionalInfo': additionalInfo,
    };
  }

  Vehicle copyWith({
    String? id,
    String? userId,
    String? licensePlate,
    String? make,
    String? model,
    String? color,
    String? type,
    bool? isPrimary,
    bool? isRegistered,
    String? parkingSlot,
    DateTime? registrationDate,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Vehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      licensePlate: licensePlate ?? this.licensePlate,
      make: make ?? this.make,
      model: model ?? this.model,
      color: color ?? this.color,
      type: type ?? this.type,
      isPrimary: isPrimary ?? this.isPrimary,
      isRegistered: isRegistered ?? this.isRegistered,
      parkingSlot: parkingSlot ?? this.parkingSlot,
      registrationDate: registrationDate ?? this.registrationDate,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
